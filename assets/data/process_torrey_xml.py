#!/usr/bin/env python3
"""
Torrey Topical Textbook XML Processor
Processes ThML (Theological Markup Language) XML file and converts to JSON
for the Flutter Bible app
"""

import json
import xml.etree.ElementTree as ET
import re
from collections import defaultdict

def parse_scripture_reference(scripref_elem):
    """Parse a scripture reference element to extract book, chapter, verse info."""
    passage = scripref_elem.get('passage', '')
    parsed = scripref_elem.get('parsed', '')
    
    if not passage and not parsed:
        return None
    
    # Try to parse the "parsed" attribute first (more structured)
    if parsed:
        # Format: |Book|Chapter|Verse|EndChapter|EndVerse|
        parts = parsed.split('|')
        if len(parts) >= 4:
            book = parts[1]
            chapter = int(parts[2]) if parts[2].isdigit() else 1
            verse = int(parts[3]) if parts[3].isdigit() else 1
            end_chapter = int(parts[4]) if len(parts) > 4 and parts[4].isdigit() else None
            end_verse = int(parts[5]) if len(parts) > 5 and parts[5].isdigit() else None
            
            return {
                'book': normalize_book_name(book),
                'chapter': chapter,
                'verse': verse,
                'end_chapter': end_chapter,
                'end_verse': end_verse,
                'reference': passage or f"{book} {chapter}:{verse}"
            }
    
    # Fallback to parsing "passage" attribute
    if passage:
        return parse_passage_string(passage)
    
    return None

def normalize_book_name(book_code):
    """Convert book codes to full names matching our WEB Bible format."""
    book_mappings = {
        'Gen': 'Genesis', 'Exod': 'Exodus', 'Lev': 'Leviticus', 'Num': 'Numbers', 'Deut': 'Deuteronomy',
        'Josh': 'Joshua', 'Judg': 'Judges', 'Ruth': 'Ruth', '1Sam': '1 Samuel', '2Sam': '2 Samuel',
        '1Kgs': '1 Kings', '2Kgs': '2 Kings', '1Chr': '1 Chronicles', '2Chr': '2 Chronicles',
        'Ezra': 'Ezra', 'Neh': 'Nehemiah', 'Esth': 'Esther', 'Job': 'Job', 'Ps': 'Psalms',
        'Prov': 'Proverbs', 'Eccl': 'Ecclesiastes', 'Song': 'Song of Songs', 'Isa': 'Isaiah',
        'Jer': 'Jeremiah', 'Lam': 'Lamentations', 'Ezek': 'Ezekiel', 'Dan': 'Daniel',
        'Hos': 'Hosea', 'Joel': 'Joel', 'Amos': 'Amos', 'Obad': 'Obadiah', 'Jonah': 'Jonah',
        'Mic': 'Micah', 'Nah': 'Nahum', 'Hab': 'Habakkuk', 'Zeph': 'Zephaniah',
        'Hag': 'Haggai', 'Zech': 'Zechariah', 'Mal': 'Malachi',
        
        # New Testament
        'Matt': 'Matthew', 'Mark': 'Mark', 'Luke': 'Luke', 'John': 'John', 'Acts': 'Acts',
        'Rom': 'Romans', '1Cor': '1 Corinthians', '2Cor': '2 Corinthians', 'Gal': 'Galatians',
        'Eph': 'Ephesians', 'Phil': 'Philippians', 'Col': 'Colossians', '1Thess': '1 Thessalonians',
        '2Thess': '2 Thessalonians', '1Tim': '1 Timothy', '2Tim': '2 Timothy', 'Titus': 'Titus',
        'Phlm': 'Philemon', 'Heb': 'Hebrews', 'Jas': 'James', '1Pet': '1 Peter', '2Pet': '2 Peter',
        '1John': '1 John', '2John': '2 John', '3John': '3 John', 'Jude': 'Jude', 'Rev': 'Revelation'
    }
    
    return book_mappings.get(book_code, book_code)

def parse_passage_string(passage):
    """Parse a passage string like 'Mt 6:6' or 'Ps 23:1,2'."""
    # This is a simplified parser - could be enhanced for more complex references
    match = re.match(r'(\w+)\s+(\d+):(\d+)', passage)
    if match:
        book, chapter, verse = match.groups()
        return {
            'book': normalize_book_name(book),
            'chapter': int(chapter),
            'verse': int(verse),
            'reference': passage
        }
    return None

def process_subtopic(p_elem, topic_title):
    """Process a subtopic paragraph element."""
    # Get the subtopic text (everything before the first scripture reference)
    subtopic_text = ""
    verses = []
    
    # Process text and scripture references
    text_parts = []
    if p_elem.text:
        text_parts.append(p_elem.text.strip())
    
    for child in p_elem:
        if child.tag == 'scripRef':
            # Parse scripture reference
            verse_ref = parse_scripture_reference(child)
            if verse_ref:
                verses.append(verse_ref)
        
        if child.text:
            text_parts.append(child.text.strip())
        if child.tail:
            text_parts.append(child.tail.strip())
    
    subtopic_text = ' '.join(text_parts).strip()
    
    # Clean up subtopic text (remove verse references and dashes)
    subtopic_text = re.sub(r'\s*—\s*$', '', subtopic_text)  # Remove trailing dash
    subtopic_text = re.sub(r'\s*\.\s*$', '', subtopic_text)  # Remove trailing period
    
    if not subtopic_text:
        subtopic_text = "General"
    
    return {
        'title': subtopic_text,
        'verses': verses
    }

def process_torrey_xml(xml_file_path):
    """Process the Torrey Topical Textbook XML file."""
    print(f"Processing Torrey XML file: {xml_file_path}")
    
    # Parse the XML file
    tree = ET.parse(xml_file_path)
    root = tree.getroot()
    
    topics = []
    current_topic = None
    topic_id = 1
    subtopic_id = 1
    
    # Find all term and definition elements
    for elem in root.iter():
        if elem.tag == 'term':
            # Start of a new topic
            topic_title = elem.text.strip() if elem.text else "Unknown Topic"
            current_topic = {
                'id': topic_id,
                'title': topic_title,
                'subtopics': []
            }
            topics.append(current_topic)
            topic_id += 1
            subtopic_id = 1
            print(f"Processing topic: {topic_title}")
            
        elif elem.tag == 'def' and current_topic:
            # Process definition content (subtopics)
            for p_elem in elem.findall('.//p[@class="index1"]'):
                subtopic = process_subtopic(p_elem, current_topic['title'])
                if subtopic['verses']:  # Only include subtopics with verses
                    subtopic['id'] = subtopic_id
                    current_topic['subtopics'].append(subtopic)
                    subtopic_id += 1
    
    return topics

def create_torrey_json(xml_file_path, output_file):
    """Create the final JSON structure for the Torrey Textbook."""
    topics = process_torrey_xml(xml_file_path)
    
    # Filter out topics without subtopics
    filtered_topics = [topic for topic in topics if topic['subtopics']]
    
    torrey_data = {
        'title': "Torrey's New Topical Textbook",
        'description': "A comprehensive topical concordance with 628+ entries and over 20,000 scripture references",
        'topics': filtered_topics
    }
    
    # Save to JSON file
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(torrey_data, f, indent=2, ensure_ascii=False)
    
    return torrey_data

def create_summary(torrey_data):
    """Create a summary of the processed Torrey data."""
    print("\n" + "="*60)
    print("TORREY TOPICAL TEXTBOOK PROCESSING COMPLETE")
    print("="*60)
    
    total_topics = len(torrey_data['topics'])
    total_subtopics = sum(len(topic['subtopics']) for topic in torrey_data['topics'])
    total_verses = sum(
        sum(len(subtopic['verses']) for subtopic in topic['subtopics'])
        for topic in torrey_data['topics']
    )
    
    print(f"📚 Total Topics: {total_topics}")
    print(f"📑 Total Subtopics: {total_subtopics}")
    print(f"📜 Total Verse References: {total_verses}")
    print()
    
    print("First 20 Topics:")
    for i, topic in enumerate(torrey_data['topics'][:20], 1):
        subtopics = len(topic['subtopics'])
        verses = sum(len(st['verses']) for st in topic['subtopics'])
        print(f"{i:2d}. {topic['title']:<35} - {subtopics:2d} subtopics, {verses:3d} verses")
    
    if total_topics > 20:
        print(f"... and {total_topics - 20} more topics")
    
    print("\n" + "="*60)

def create_cross_reference_index(torrey_data, bible_data_file):
    """Create a cross-reference index linking Bible verses to Torrey topics."""
    # This would link specific Bible verses to the topics that reference them
    # For now, just create the structure
    cross_ref = {
        'verse_to_topics': {},  # Maps "Book Chapter:Verse" to list of topic IDs
        'topic_to_verses': {}   # Maps topic IDs to list of verse references
    }
    
    for topic in torrey_data['topics']:
        topic_id = topic['id']
        cross_ref['topic_to_verses'][topic_id] = []
        
        for subtopic in topic['subtopics']:
            for verse in subtopic['verses']:
                verse_key = f"{verse['book']} {verse['chapter']}:{verse['verse']}"
                
                # Add to verse-to-topics mapping
                if verse_key not in cross_ref['verse_to_topics']:
                    cross_ref['verse_to_topics'][verse_key] = []
                cross_ref['verse_to_topics'][verse_key].append(topic_id)
                
                # Add to topic-to-verses mapping
                cross_ref['topic_to_verses'][topic_id].append(verse_key)
    
    return cross_ref

if __name__ == "__main__":
    # Configuration
    xml_file = "/home/rdmerrio/gits/torrey/torrey_bible_app/assets/data/torrey_xml_file/ttt.xml"
    output_file = "/home/rdmerrio/gits/torrey/torrey_bible_app/assets/data/torrey_topics_complete.json"
    
    # Process the XML file
    torrey_data = create_torrey_json(xml_file, output_file)
    
    # Show summary
    create_summary(torrey_data)
    
    # Create cross-reference index
    cross_ref_file = "/home/rdmerrio/gits/torrey/torrey_bible_app/assets/data/torrey_cross_reference.json"
    cross_ref = create_cross_reference_index(torrey_data, None)
    
    with open(cross_ref_file, 'w', encoding='utf-8') as f:
        json.dump(cross_ref, f, indent=2, ensure_ascii=False)
    
    print(f"\n📋 Cross-reference index saved to: {cross_ref_file}")
    print(f"🎯 Main Torrey data saved to: {output_file}")