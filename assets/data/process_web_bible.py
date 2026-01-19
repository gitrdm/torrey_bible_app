#!/usr/bin/env python3
"""
WEB Bible Text Processor - Enhanced Version
Processes WEB Bible text files with filename format: engwebu_###_BOOK_##_read.txt
Converts to structured JSON format for Flutter app
"""

import json
import re
import os
from pathlib import Path
from collections import defaultdict

# Book name mappings from filename codes to proper names
BOOK_MAPPINGS = {
    'GEN': 'Genesis', 'EXO': 'Exodus', 'LEV': 'Leviticus', 'NUM': 'Numbers', 'DEU': 'Deuteronomy',
    'JOS': 'Joshua', 'JDG': 'Judges', 'RUT': 'Ruth', '1SA': '1 Samuel', '2SA': '2 Samuel',
    '1KI': '1 Kings', '2KI': '2 Kings', '1CH': '1 Chronicles', '2CH': '2 Chronicles',
    'EZR': 'Ezra', 'NEH': 'Nehemiah', 'EST': 'Esther', 'JOB': 'Job', 'PSA': 'Psalms',
    'PRO': 'Proverbs', 'ECC': 'Ecclesiastes', 'SNG': 'Song of Songs', 'ISA': 'Isaiah',
    'JER': 'Jeremiah', 'LAM': 'Lamentations', 'EZK': 'Ezekiel', 'DAN': 'Daniel',
    'HOS': 'Hosea', 'JOL': 'Joel', 'AMO': 'Amos', 'OBA': 'Obadiah', 'JON': 'Jonah',
    'MIC': 'Micah', 'NAM': 'Nahum', 'HAB': 'Habakkuk', 'ZEP': 'Zephaniah',
    'HAG': 'Haggai', 'ZEC': 'Zechariah', 'MAL': 'Malachi',
    
    # New Testament
    'MAT': 'Matthew', 'MRK': 'Mark', 'LUK': 'Luke', 'JHN': 'John', 'ACT': 'Acts',
    'ROM': 'Romans', '1CO': '1 Corinthians', '2CO': '2 Corinthians', 'GAL': 'Galatians',
    'EPH': 'Ephesians', 'PHP': 'Philippians', 'COL': 'Colossians', '1TH': '1 Thessalonians',
    '2TH': '2 Thessalonians', '1TI': '1 Timothy', '2TI': '2 Timothy', 'TIT': 'Titus',
    'PHM': 'Philemon', 'HEB': 'Hebrews', 'JAS': 'James', '1PE': '1 Peter', '2PE': '2 Peter',
    '1JN': '1 John', '2JN': '2 John', '3JN': '3 John', 'JUD': 'Jude', 'REV': 'Revelation',
    
    # Apocryphal books (included in WEB)
    'TOB': 'Tobit', 'JDT': 'Judith', 'ESG': 'Esther (Greek)', 'WIS': 'Wisdom',
    'SIR': 'Sirach', 'BAR': 'Baruch', '1MA': '1 Maccabees', '2MA': '2 Maccabees',
    '1ES': '1 Esdras', 'MAN': 'Prayer of Manasseh', 'PS2': 'Psalm 151',
    '3MA': '3 Maccabees', '2ES': '2 Esdras', '4MA': '4 Maccabees', 'DAG': 'Daniel (Greek)'
}

def parse_filename(filename):
    """Parse filename to extract book code and chapter number."""
    # Pattern: engwebu_###_BOOK_##_read.txt
    pattern = r'engwebu_\d{3}_([A-Z0-9]+)_(\d+)_read\.txt'
    match = re.match(pattern, filename)
    if match:
        book_code = match.group(1)
        chapter_num = int(match.group(2))
        return book_code, chapter_num
    return None, None

def parse_bible_file(file_path):
    """Parse a WEB Bible text file and extract structured data."""
    filename = os.path.basename(file_path)
    book_code, chapter_num = parse_filename(filename)
    
    if not book_code:
        print(f"Warning: Could not parse filename {filename}")
        return None
    
    # Get proper book name
    book_name = BOOK_MAPPINGS.get(book_code, book_code)
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # First line usually contains the book title, second line chapter
    verses = []
    verse_number = 1
    
    # Skip first two lines (book title and chapter header)
    for line in lines[2:]:
        line = line.strip()
        if line:  # Skip empty lines
            verses.append({
                'verse': verse_number,
                'text': line
            })
            verse_number += 1
    
    return {
        'book': book_name,
        'book_code': book_code,
        'chapter': chapter_num,
        'verses': verses
    }

def process_all_bible_files(input_dir, output_file):
    """Process all Bible files and create structured JSON."""
    print(f"Processing Bible files from: {input_dir}")
    
    # Group chapters by book
    books_data = defaultdict(lambda: {'chapters': []})
    
    # Process all matching files
    input_path = Path(input_dir)
    txt_files = list(input_path.glob('engwebu_*_read.txt'))
    
    print(f"Found {len(txt_files)} Bible files")
    
    processed_count = 0
    for txt_file in sorted(txt_files):  # Sort for consistent ordering
        chapter_data = parse_bible_file(txt_file)
        
        if chapter_data:
            book_name = chapter_data['book']
            book_code = chapter_data['book_code']
            
            # Initialize book if first time seeing it
            if 'book' not in books_data[book_name]:
                books_data[book_name]['book'] = book_name
                books_data[book_name]['book_code'] = book_code
            
            # Add chapter
            books_data[book_name]['chapters'].append({
                'chapter': chapter_data['chapter'],
                'verses': chapter_data['verses']
            })
            
            processed_count += 1
            if processed_count % 50 == 0:
                print(f"Processed {processed_count} files...")
    
    # Convert to final format and sort chapters
    bible_data = {'books': []}
    for book_name in sorted(books_data.keys()):
        book_info = books_data[book_name]
        
        # Sort chapters by chapter number
        book_info['chapters'].sort(key=lambda x: x['chapter'])
        
        bible_data['books'].append(book_info)
    
    # Write to output file
    print(f"Writing to: {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(bible_data, f, indent=2, ensure_ascii=False)
    
    return bible_data

def create_summary(bible_data):
    """Create a summary of processed data."""
    print("\n" + "="*60)
    print("BIBLE PROCESSING COMPLETE")
    print("="*60)
    
    total_books = len(bible_data['books'])
    total_chapters = sum(len(book['chapters']) for book in bible_data['books'])
    total_verses = sum(
        sum(len(chapter['verses']) for chapter in book['chapters'])
        for book in bible_data['books']
    )
    
    print(f"📖 Total Books: {total_books}")
    print(f"📋 Total Chapters: {total_chapters}")
    print(f"📜 Total Verses: {total_verses}")
    print()
    
    print("Books processed:")
    for i, book in enumerate(bible_data['books'], 1):
        chapters = len(book['chapters'])
        verses = sum(len(ch['verses']) for ch in book['chapters'])
        print(f"{i:2d}. {book['book']:<20} - {chapters:3d} chapters, {verses:4d} verses")
    
    print("\n" + "="*60)

if __name__ == "__main__":
    # Configuration
    input_dir = "/home/rdmerrio/gits/torrey/torrey_bible_app/assets/data/web_bible_text"
    output_file = "/home/rdmerrio/gits/torrey/torrey_bible_app/assets/data/web_bible_complete.json"
    
    # Process all files
    bible_data = process_all_bible_files(input_dir, output_file)
    
    # Show summary
    create_summary(bible_data)