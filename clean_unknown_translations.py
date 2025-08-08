#!/usr/bin/env python3

import re
import sys

def clean_unknown_translations(file_path):
    print(f"Processing {file_path}...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Count original entries
    original_unknown_count = content.count("'translation': 'Unknown'")
    print(f"Found {original_unknown_count} entries with 'translation': 'Unknown'")
    
    # Pattern to match entire entries with 'translation': 'Unknown'
    # This pattern matches from the word key until the closing brace and comma
    pattern = r"^\s*'([^']+)':\s*\{\s*'translation':\s*'Unknown',?\s*(?:[^}]*?)?\},?\s*$"
    
    # Also match entries that only have translation: Unknown
    simple_pattern = r"^\s*'([^']+)':\s*\{\s*'translation':\s*'Unknown'\s*\},?\s*$"
    
    lines = content.split('\n')
    new_lines = []
    i = 0
    removed_count = 0
    removed_words = []
    
    while i < len(lines):
        line = lines[i]
        
        # Check if this line starts an entry with 'translation': 'Unknown'
        if "'translation': 'Unknown'" in line:
            # Find the word key
            word_match = re.search(r"'([^']+)':\s*{", line)
            if word_match:
                word = word_match.group(1)
                removed_words.append(word)
                removed_count += 1
                
                # Skip this entire entry
                if line.strip().endswith('},'):
                    # Single line entry
                    i += 1
                    continue
                else:
                    # Multi-line entry - skip until we find the closing brace
                    i += 1
                    while i < len(lines) and not lines[i].strip().endswith('},'):
                        i += 1
                    i += 1  # Skip the closing line too
                    continue
        
        new_lines.append(line)
        i += 1
    
    # Write the cleaned content
    new_content = '\n'.join(new_lines)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"Removed {removed_count} entries with 'translation': 'Unknown'")
    print(f"Removed words: {', '.join(removed_words[:10])}{' ...' if len(removed_words) > 10 else ''}")
    
    # Verify
    with open(file_path, 'r', encoding='utf-8') as f:
        new_content = f.read()
    
    remaining_unknown = new_content.count("'translation': 'Unknown'")
    print(f"Remaining 'translation': 'Unknown' entries: {remaining_unknown}")
    
    return removed_count, removed_words

if __name__ == "__main__":
    files_to_clean = [
        "/Users/seanellul/Code/Flutter/Maltese Wordle Game/FLUTTER-BUILD/werdil/lib/utils/word_translations.dart",
        "/Users/seanellul/Code/Flutter/Maltese Wordle Game/FLUTTER-BUILD/werdil/lib/utils/word_translations_complete.dart"
    ]
    
    total_removed = 0
    all_removed_words = []
    
    for file_path in files_to_clean:
        try:
            removed, words = clean_unknown_translations(file_path)
            total_removed += removed
            all_removed_words.extend(words)
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
    
    print(f"\n=== SUMMARY ===")
    print(f"Total entries removed: {total_removed}")
    print(f"Total unique words removed: {len(set(all_removed_words))}")
    print("Files processed successfully!")