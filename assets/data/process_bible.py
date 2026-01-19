#!/usr/bin/env python3
"""
WEB Bible Text Processor
Converts WEB Bible text files into JSON format for Flutter app
"""

import json
import re
import os
from pathlib import Path

def parse_bible_file(file_path):
    """Parse a WEB Bible text file and extract structured data."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract book name from first line
    lines = content.strip().split('\n')
    book_title = lines[0].replace('The First Book of Moses, Commonly Called ', '').replace('.', '')
    book_name = book_title.split(',')[0] if ',' in book_title else book_title
    
    chapters = []
    current_chapter = None
    verse_number = 1
    
    for line in lines[1:]:
        line = line.strip()
        if not line:
            continue
            
        # Check if line is a chapter header
        if line.startswith('Chapter ') and line.endswith('.'):
            if current_chapter:
                chapters.append(current_chapter)
            
            chapter_num = int(line.replace('Chapter ', '').replace('.', ''))
            current_chapter = {
                'chapter': chapter_num,
                'verses': []
            }
            verse_number = 1
        else:
            # This is a verse
            if current_chapter:
                current_chapter['verses'].append({
                    'verse': verse_number,
                    'text': line
                })
                verse_number += 1
    
    # Add the last chapter
    if current_chapter:
        chapters.append(current_chapter)
    
    return {
        'book': book_name,
        'chapters': chapters
    }

def process_bible_files(input_dir, output_file):
    """Process all Bible files in directory and create combined JSON."""
    bible_data = {
        'books': []
    }
    
    # Process all .txt files in input directory
    for txt_file in Path(input_dir).glob('*.txt'):
        if 'sample_' in txt_file.name:  # Skip our sample file
            print(f"Processing: {txt_file.name}")
            book_data = parse_bible_file(txt_file)
            bible_data['books'].append(book_data)
    
    # Write to output JSON file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(bible_data, f, indent=2, ensure_ascii=False)
    
    print(f"Bible data saved to: {output_file}")
    return bible_data

if __name__ == "__main__":
    # Process sample file for testing
    input_dir = "/home/rdmerrio/gits/torrey/torrey_bible_app/assets/data"
    output_file = "/home/rdmerrio/gits/torrey/torrey_bible_app/assets/data/web_bible.json"
    
    bible_data = process_bible_files(input_dir, output_file)
    
    # Print summary
    print(f"\nProcessed {len(bible_data['books'])} books:")
    for book in bible_data['books']:
        print(f"  - {book['book']}: {len(book['chapters'])} chapters")
        total_verses = sum(len(ch['verses']) for ch in book['chapters'])
        print(f"    Total verses: {total_verses}")