#!/usr/bin/env ruby

# https://github.com/omrapp/xml-to-localizable

require 'fileutils'
require 'pathname'
require 'rexml/document'
require 'find'
require 'iconv'

# The project path we are running in. Should be the project root directory.
project_path = Pathname.pwd
project_name = ARGV.first
puts "#{project_path}"
puts "#{project_name}"

# The path to Android's res directory, where the values-?? folders live.
res_path = project_path + project_name

# Stuff base strings in here
base_strings = {}


unless res_path.exist?
    puts "Error! android_res directory not found: #{res_path}"
    Process.exit!(true)
end


# Replace positional variable placeholders for strings with @'s.
def translate_placeholders(str)
    if str
        str.gsub!(/(%\d\$s)/i, "%@")
        str.gsub!(/(%\d\$d)/i, "%@")
        #        str.scan(/%\d\$s/i) { |p|
        #            str = str.gsub(/%\d\$s/i, p.gsub(/s/i, "@"))
        #        }
    end
    
    str
end



# Loop thru the values-?? dirs in the res_path.
res_path.each_entry { |values_dir|
    #next unless values_dir.fnmatch? 'values*'
    
    #values_path = res_path + values_dir
    next unless (res_path + 'arrays.xml').exist? || (res_path + 'constants.xml').exist? || (res_path + 'strings.xml').exist?
    
    # Set the base language to use.
    base_language = 'en.lproj'
    
    # Build the destination path.
    dest_path = project_path + project_name + 'generated' + base_language
    
    
    # If the dest dir does not exist, warn and continue.
    unless dest_path.exist?
        puts "Warning! iOS localization not set up for '#{dest_dir}'. Skipping."
        puts "Expected destination path: '#{dest_path.to_s}'"
        next
    end
    
    # Stuff the strings in here.
    strings = {}
    
    # Process the arrays.xml, constants.xml, and strings.xml files.
    %w[strings.xml].each { |src_file|
        src_path = res_path + src_file
        next unless src_path.exist?
        
        xml = File.read src_path.to_s
        doc = REXML::Document.new(xml)
        
        # Process non-array string elements.
        #puts "#{src_path}"
        doc.elements.each('resources/string') { |str|
            key = str.attributes['name'].to_s.strip
            # puts "#{key.class}"
            # Look for <a><u>Value</u></a> sub elements
            until str.has_elements? == false
                str.each_element { |astr|
                    str = astr
                }
            end
            
            next if key.include? "html"
            
            value = translate_placeholders(str.text).to_s.strip
            
            if value
                base_strings[key] = value
                else
                base_strings[key] = ""
            end
        }
    }
    
    # If Localizable.strings exists, remove it.
    loc_str_path = dest_path + 'Localizable.strings'
    loc_str_path.delete if loc_str_path.exist?
    
    # Write the new Localizable.strings file.
    converter = Iconv.new 'utf-8', ''
    File.open(loc_str_path, 'wb') { |f|
        
        #base_strings.keys.sort.each { |key|
        base_strings.sort_by { |k,v| v }.each { |key, value|
            base_value = base_strings[key]
            value = strings.keys.include?(key) ? strings[key] : base_value
            
            unless key.include? ','
                base_value = key if key.match(/-\d+\z/)
            end
            
            f.write converter.iconv "/*@ #{key} */\n"
            f.write converter.iconv "\"#{key}\" = \"#{value}\";\n\n"
        }
    }
    
    
}


