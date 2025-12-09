#!/usr/bin/env python3
"""
Intel HEX Decoder for IFS Firmware Analysis
Decodes Intel HEX format to binary and extracts memory layout information
"""

import binascii
import struct
from collections import defaultdict

def parse_intel_hex_line(line):
    """Parse a single Intel HEX line"""
    if not line.startswith(':'):
        return None
    
    # Remove the colon and any whitespace
    line = line.strip()[1:]
    if len(line) < 10:
        return None
    
    try:
        # Parse hex data
        data = binascii.unhexlify(line)
        
        # Extract fields
        byte_count = data[0]
        address = struct.unpack('>H', data[1:3])[0]
        record_type = data[3]
        record_data = data[4:4+byte_count]
        checksum = data[4+byte_count]
        
        # Verify checksum
        calculated_checksum = (256 - sum(data[:-1]) % 256) % 256
        if calculated_checksum != checksum:
            print(f"Checksum mismatch: calculated {calculated_checksum:02X}, got {checksum:02X}")
            return None
        
        return {
            'byte_count': byte_count,
            'address': address,
            'record_type': record_type,
            'data': record_data,
            'checksum': checksum
        }
    except Exception as e:
        print(f"Error parsing line: {e}")
        return None

def decode_hex_file(filename):
    """Decode entire Intel HEX file"""
    memory_data = bytearray()
    memory_map = defaultdict(bytes)
    extended_address = 0
    
    with open(filename, 'r') as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
                
            record = parse_intel_hex_line(line)
            if record is None:
                continue
                
            if record['record_type'] == 0:  # Data record
                # Apply extended address if set
                full_address = (extended_address << 16) + record['address']
                memory_map[full_address] = record['data']
                
            elif record['record_type'] == 1:  # End of file
                print(f"End of file record found at line {line_num}")
                break
                
            elif record['record_type'] == 4:  # Extended Linear Address
                if record['byte_count'] == 2:
                    extended_address = struct.unpack('>H', record['data'])[0]
                    print(f"Extended address set to 0x{extended_address:04X}")
                    
            elif record['record_type'] == 5:  # Start Linear Address
                if record['byte_count'] == 4:
                    start_address = struct.unpack('>I', record['data'])[0]
                    print(f"Start address: 0x{start_address:08X}")
    
    return memory_map, extended_address

def analyze_memory_layout(memory_map):
    """Analyze the memory layout and identify sections"""
    if not memory_map:
        print("No memory data found!")
        return
    
    # Sort by address
    sorted_addresses = sorted(memory_map.keys())
    
    print(f"\nMemory Layout Analysis:")
    print(f"Total data records: {len(memory_map)}")
    
    # Find contiguous blocks
    blocks = []
    if sorted_addresses:
        current_block = {'start': sorted_addresses[0], 'end': sorted_addresses[0], 'size': 0}
        
        for addr in sorted_addresses:
            data_size = len(memory_map[addr])
            if addr == current_block['end'] + len(memory_map.get(current_block['end'], b'')):
                current_block['end'] = addr + data_size - 1
            else:
                blocks.append(current_block)
                current_block = {'start': addr, 'end': addr + data_size - 1, 'size': data_size}
        
        blocks.append(current_block)
    
    print(f"\nMemory blocks:")
    for i, block in enumerate(blocks):
        size = block['end'] - block['start'] + 1
        print(f"  Block {i+1}: 0x{block['start']:08X} - 0x{block['end']:08X} ({size} bytes)")
    
    return blocks, sorted_addresses

def extract_strings(memory_map, min_length=4):
    """Extract readable strings from memory"""
    all_strings = []
    
    for addr, data in memory_map.items():
        # Try to extract strings from the data
        current_string = ""
        start_addr = addr
        
        for i, byte in enumerate(data):
            if 32 <= byte <= 126:  # Printable ASCII
                current_string += chr(byte)
            else:
                if len(current_string) >= min_length:
                    all_strings.append((start_addr, current_string))
                current_string = ""
                start_addr = addr + i + 1
        
        if len(current_string) >= min_length:
            all_strings.append((start_addr, current_string))
    
    return all_strings

def main():
    print("IFS Firmware HEX Decoder")
    print("=" * 40)
    
    # Decode the hex file
    memory_map, extended_addr = decode_hex_file('/workspace/ifs.hex')
    
    # Analyze memory layout
    blocks, addresses = analyze_memory_layout(memory_map)
    
    # Extract strings for analysis
    strings = extract_strings(memory_map)
    
    print(f"\nExtracted Strings ({len(strings)} found):")
    for addr, string in sorted(strings)[:20]:  # Show first 20
        print(f"  0x{addr:08X}: {string}")
    
    # Save binary data for further analysis
    if memory_map:
        # Create contiguous binary file
        min_addr = min(addresses)
        max_addr = max(addresses) + len(memory_map[max(addresses)])
        
        binary_data = bytearray(max_addr - min_addr)
        for addr, data in memory_map.items():
            offset = addr - min_addr
            binary_data[offset:offset+len(data)] = data
        
        with open('/workspace/ifs_binary.bin', 'wb') as f:
            f.write(binary_data)
        
        print(f"\nBinary data saved to: ifs_binary.bin")
        print(f"Address range: 0x{min_addr:08X} - 0x{max_addr-1:08X}")
        print(f"Total size: {len(binary_data)} bytes")

if __name__ == "__main__":
    main()