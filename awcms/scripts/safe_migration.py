import re
import os
import sys

def make_safe(content):
    def is_commented(pos, content):
        # Check if the line containing pos starts with --
        line_start = content.rfind('\n', 0, pos) + 1
        return content[line_start:pos].strip().startswith('--')

    def is_already_wrapped(pos, content):
        before = content[:pos]
        last_do = before.rfind("DO $$")
        last_end = before.rfind("END $$")
        return last_do > last_end

    # Pattern for constraints
    pattern_constraint = r'ALTER TABLE\s+(?:ONLY\s+)?(?:"?public"?\.)?"?([^"\s\(\)]+)"?\s+ADD CONSTRAINT\s+"?([^"\s]+)"?\s+(PRIMARY KEY|UNIQUE|CHECK|FOREIGN KEY)\s+([^;]+);'
    
    new_content = ""
    last_pos = 0
    for match in re.finditer(pattern_constraint, content, flags=re.MULTILINE | re.IGNORECASE):
        new_content += content[last_pos:match.start()]
        if is_commented(match.start(), content) or is_already_wrapped(match.start(), content):
            new_content += match.group(0)
        else:
            table = match.group(1)
            constraint = match.group(2)
            type_str = match.group(3)
            rest = match.group(4)
            new_content += f"""DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = '{constraint}') THEN
        ALTER TABLE ONLY "public"."{table}" ADD CONSTRAINT "{constraint}" {type_str} {rest};
    END IF;
END $$;"""
        last_pos = match.end()
    new_content += content[last_pos:]
    content = new_content

    # Pattern for indexes
    pattern_index = r'CREATE\s+(UNIQUE\s+)?INDEX\s+"?([^"\s]+)"?\s+ON\s+(?:"?public"?\.)?"?([^"\s]+)"?\s+([^;]+);'
    new_content = ""
    last_pos = 0
    for match in re.finditer(pattern_index, content, flags=re.MULTILINE | re.IGNORECASE):
        new_content += content[last_pos:match.start()]
        if is_commented(match.start(), content) or is_already_wrapped(match.start(), content):
            new_content += match.group(0)
        else:
            unique = match.group(1) or ""
            name = match.group(2)
            table = match.group(3)
            rest = match.group(4)
            new_content += f"""DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE c.relname = '{name}' AND n.nspname = 'public') THEN
        CREATE {unique}INDEX "{name}" ON "public"."{table}" {rest};
    END IF;
END $$;"""
        last_pos = match.end()
    new_content += content[last_pos:]
    content = new_content

    return content

if __name__ == "__main__":
    for file_path in sys.argv[1:]:
        with open(file_path, 'r') as f:
            content = f.read()
        
        new_content = make_safe(content)
        
        with open(file_path, 'w') as f:
            f.write(new_content)
