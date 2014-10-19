require 'mechanize'
require 'uri'
require 'net/http'

BASE_URL = 'https://developer.mozilla.org'
DOWNLOAD_DIR = './downloaded'

KIND_GLOBAL_PROPERTY = 'GlobalProperty'
KIND_GLOBAL_FUNCTION =  'GlobalFunction'
KIND_CLASS =  'Class'
KIND_CLASS_METHOD =  'ClassMethod'
KIND_CLASS_PROPERTY =  'ClassProperty'
KIND_METHOD = 'Method'
KIND_PROPERTY = 'Property'

class JavascriptDocPopulator

  def initialize(output_path)
    @output_path = output_path
  end

  def download
    puts "Starting download ..."

    FileUtils.mkpath(DOWNLOAD_DIR)

    agent = Mechanize.new
    page = agent.get("#{BASE_URL}/en-US/docs/Web/JavaScript/Reference/Global_Objects")

    page.search('.onlyinclude li a').each do |a|
      name = a.text().strip

      name = name.gsub(/\(\)/, '')
      uri = URI.parse(BASE_URL + a['href'])

      output_path = "#{DOWNLOAD_DIR}/#{name}.html"

      if !File.exist?(output_path)
        puts "Downloading page for #{name} ..."
        puts "URI = #{uri}"

        response = Net::HTTP.get_response(uri)
        File.write(output_path, response.body)

        puts "Done downloading page for top-level object #{name}, sleeping ..."

        sleep(1)
      end

      if name[0] == name[0].upcase
        FileUtils.mkpath(DOWNLOAD_DIR + '/' + name)

        File.open(output_path) do |f|
          doc = Nokogiri::HTML(f)

          doc.css('dt a').each do |a2|
            name2 = a2.css('code').text()
            output_path2 = "#{DOWNLOAD_DIR}/#{name}/#{name2}.html"

            if !File.exist?(output_path2)
              begin
                uri2 = URI.parse(BASE_URL + a2['href'])
                response2 = Net::HTTP.get_response(uri2)
                File.write(output_path2, response2.body)
                puts "Done downloading page for 2nd-level item  #{name2}, sleeping ..."
              rescue => ex
                puts "Failed to download page for 2nd-level item #{name2}"
                puts ex.backtrace
              end
              sleep(1)
            end
          end
        end
      end
    end

    puts "Done downloading!"
  end

  def populate
    @first_document = true

    num_docs_found = 0

    File.open(@output_path, 'w:UTF-8') do |out|
      out.write <<-eos
{
  "metadata" : {
    "mapping" : {
      "_all" : {
        "enabled" : false
      },
      "properties" : {
        "qualifiedName" : {
          "type" : "string",
          "index" : "analyzed",
          "analyzer" : "simple"
        },
        "simpleName" : {
          "type" : "string",
          "index" : "analyzed",
          "analyzer" : "simple"
        },
        "class" : {
          "type" : "string",
          "index" : "analyzed",
          "analyzer" : "simple"
        },
        "syntax" : {
          "type" : "string",
          "index" : "no"
        },
        "summaryHtml" : {
          "type" : "string",
          "index" : "no"
        },
        "descriptionHtml" : {
          "type" : "string",
          "index" : "no"
        },
        "url" : {
          "type" : "string",
          "index" : "no"
        },
        "kind" : {
          "type" : "string",
          "index" : "no"
        },
        "deprecated" : {
          "type" : "boolean",
          "index" : "no"
        },
        "ecma6" : {
          "type" : "boolean",
          "index" : "no"
        },
        "nonStandard" : {
          "type" : "boolean",
          "index" : "no"
        },
        "constructor" : {
          "type" : "object",
          "properties" : {
            "name" : {
              "type" : "string",
              "index" : "no"
            },
            "descriptionHtml" : {
              "type" : "string",
              "index" : "no"
            }
          }
        },
        "classProps" : {
          "type" : "object",
          "properties" : {
            "simpleName" : {
              "type" : "string",
              "index" : "no"
            },
            "summaryHtml" : {
              "type" : "string",
              "index" : "no"
            },
            "url" : {
              "type" : "string",
              "index" : "no"
            },
            "deprecated" : {
              "type" : "boolean",
              "index" : "no"
            },
            "ecma6" : {
              "type" : "boolean",
              "index" : "no"
            },
            "nonStandard" : {
              "type" : "boolean",
              "index" : "no"
            }
          }
        },
        "classMethods" : {
          "type" : "object",
          "properties" : {
            "simpleName" : {
              "type" : "string",
              "index" : "no"
            },
            "summaryHtml" : {
              "type" : "string",
              "index" : "no"
            },
            "url" : {
              "type" : "string",
              "index" : "no"
            },
            "deprecated" : {
              "type" : "boolean",
              "index" : "no"
            },
            "ecma6" : {
              "type" : "boolean",
              "index" : "no"
            },
            "nonStandard" : {
              "type" : "boolean",
              "index" : "no"
            }
          }
        },
        "props" : {
          "type" : "object",
          "properties" : {
            "simpleName" : {
              "type" : "string",
              "index" : "no"
            },
            "summaryHtml" : {
              "type" : "string",
              "index" : "no"
            },
            "url" : {
              "type" : "string",
              "index" : "no"
            },
            "deprecated" : {
              "type" : "boolean",
              "index" : "no"
            },
            "ecma6" : {
              "type" : "boolean",
              "index" : "no"
            },
            "nonStandard" : {
              "type" : "boolean",
              "index" : "no"
            }
          }
        },
        "methods" : {
          "type" : "object",
          "properties" : {
            "simpleName" : {
              "type" : "string",
              "index" : "no"
            },
            "summaryHtml" : {
              "type" : "string",
              "index" : "no"
            },
            "url" : {
              "type" : "string",
              "index" : "no"
            },
            "deprecated" : {
              "type" : "boolean",
              "index" : "no"
            },
            "ecma6" : {
              "type" : "boolean",
              "index" : "no"
            },
            "nonStandard" : {
              "type" : "boolean",
              "index" : "no"
            }
          }
        },
        "returnValueDescriptionHtml" : {
          "type" : "string",
          "index" : "no"
        },
        "errorsThrownHtml" : {
          "type" : "string",
          "index" : "no"
        }
      }
    }
  },
  "updates" : [
    eos

      Dir["#{DOWNLOAD_DIR}/*.html"].each do |file_path|
        parse_file(file_path, out)
        num_docs_found += 1
      end

      out.write("\n  ]\n}")
    end

    puts "Found #{num_docs_found} docs."
  end

  private

  def parse_file(file_path, out)
    simple_filename = File.basename(file_path)

    if simple_filename.start_with?('ParallelArray') || simple_filename.start_with?('uneval') ||
       simple_filename.start_with?('Generator') || simple_filename.start_with?('Iterator')
      puts("Skipping obsolete file #{simple_filename}")
    elsif (simple_filename[0].upcase == simple_filename[0]) &&
        !simple_filename.start_with?('NaN') &&
        !simple_filename.start_with?('Infinity') &&
        simple_filename != 'Intl.html'
      class_doc = parse_class_file(file_path)
      class_name = class_doc[:class]

      Dir["#{DOWNLOAD_DIR}/#{class_name}/*.html"].each do |member_file_path|
        member_doc = parse_member_file(class_name, member_file_path)

        update_class_doc_with_member(class_doc, member_doc)
        
        write_doc(member_doc, out)
      end

      write_doc(class_doc, out)
    else
       member_doc = parse_member_file(nil, file_path)
       write_doc(member_doc, out)
    end
  end

  def write_doc(doc, out)
    if @first_document
      @first_document = false
    else
      out.write(",\n")
    end

    out.write(doc.to_json)
  end

  def parse_class_file(file_path)
    simple_filename = File.basename(file_path)

    class_name = simple_filename[0, simple_filename.length - 5]
    member_prefix = class_name + '.'
    instance_prefix = member_prefix + 'prototype.'

    puts "Parsing file '#{file_path}' for class #{class_name} ..."

    constructor_params = nil
    class_props = []
    props = []
    class_methods = []
    methods = []
    ecma6 = false
    class_summary_html = nil
    class_description_html = nil

    File.open(file_path) do |f|
      doc = Nokogiri::HTML(f)

      ecma6 = doc.css('.overheadIndicator').text().include?('ECMAScript 6')

      class_summary_html = get_next_element_html(doc, '#Summary')
      class_description_html = get_next_element_html(doc, '#Description')

      parameters_dl = doc.css('#Parameters ~ dl').first

      if parameters_dl
        puts "Found parameters dl"

        constructor_params = []

        parameters_dl.css('dt').each do |dt|
          name = dt.text()
          dd = dt.next_element
          description_html = nil

          if dd
            description_html = dd.inner_html()
          end

          name = name.strip

          constructor_params << {
              name: name,
              descriptionHtml: strip(description_html)
          }
        end
      else
        puts "Can't find parameters dl"
      end

      class_properties_dl = doc.css('#Properties ~ dl').first

      if class_properties_dl
        class_properties_dl.css('dt').each do |dt|
          name = nil
          url = nil
          a = dt.css('a')
          if a.empty?
            name = dt.css('code').text()
          else
            name = dt.css('a code').text()
            url = a.first['href']
          end

          dd = dt.next_element
          summary_html = nil

          if dd
            summary_html = dd.inner_html()
          end

          name = name.strip

          qualified_name = name
          simple_name = qualified_name.gsub(member_prefix, '')

          output_doc = {
            simpleName: simple_name,
            summaryHtml: strip(summary_html)
          }

          if url
            output_doc[:url] = BASE_URL + url.strip
          end

          class_props << output_doc
        end
      end

      class_methods_dl = doc.css('#Methods ~ dl').find do |dl|
        !dl.css('dt').empty?
      end

      if class_methods_dl
        class_methods_dl.css('dt').each do |dt|
          name = nil
          url = nil
          a = dt.css('a')
          if a.empty?
            name = dt.css('code').text()
          else
            name = dt.css('a code').text()
            url = a.first['href']
          end

          dd = dt.next_element
          summary_html = nil

          if dd
            summary_html = dd.inner_html()
          end

          name = name.strip
          qualified_name = name.gsub(/\(.*\)/, '')

          simple_name = qualified_name.gsub(member_prefix, '')

          output_doc = {
            simpleName: simple_name,
            summaryHtml: strip(summary_html)
          }

          if url
            output_doc[:url] = BASE_URL + url.strip
          end

          class_methods << output_doc
        end
      end

      found_id = ["#Properties_2", "#Properties_of_#{class_name}_instances", "#Properties_of_#{class_name.downcase}_instances"].find do |id|
        doc.css(id).first
      end

      if found_id
        properties_dl = doc.css("#{found_id} ~ dl, #{found_id} ~ * dl").first

        if properties_dl
          properties_dl.css('dt').each do |dt|
            name = nil
            url = nil
            a = dt.css('a')
            if a.empty?
              name = dt.css('code').text()
            else
              name = dt.css('a code').text()
              url = a.first['href']
            end

            dd = dt.next_element
            summary_html = nil

            if dd
              summary_html = dd.inner_html()
            end

            name = name.strip

            unless name.empty?
              qualified_name = name
              simple_name = qualified_name.gsub(instance_prefix, '')

              output_doc = {
                simpleName: simple_name,
                summaryHtml: strip(summary_html)
              }

              if url
                output_doc[:url] = BASE_URL + url.strip
              end

              props << output_doc
            end
          end
        end
      end

      found_id = ["#Methods_2", "#Methods_of_#{class_name}_instances", "#Methods_of_#{class_name.downcase}_instances"].find do |id|
        doc.css(id).first
      end

      if found_id
        methods_dl = doc.css("#{found_id} ~ dl, #{found_id} ~ * dl").first

        if methods_dl
          methods_dl.css('dt').each do |dt|
            name = nil
            url = nil
            a = dt.css('a')
            if a.empty?
              name = dt.css('code').text()
            else
              name = dt.css('a code').text()
              url = a.first['href']
            end

            dd = dt.next_element
            summary_html = nil

            if dd
              summary_html = dd.inner_html()
            end

            name = name.strip
            qualified_name = class_name + name[instance_prefix.length - 1, name.length]
            qualified_name = qualified_name.gsub(/\(.*\)/, '')
            simple_name = qualified_name.gsub(member_prefix, '')

            output_doc = {
              simpleName: simple_name,
              summaryHtml: strip(summary_html)
            }

            if url
              output_doc[:url] = BASE_URL + url.strip
            end

            methods << output_doc
          end
        end
      end
    end

    puts "Done parsing file for class #{class_name}."

    output_doc = {
      _id: class_name,
      class: class_name,
      qualifiedName: class_name,
      simpleName: class_name,
      summaryHtml: class_summary_html,
      descriptionHtml: class_description_html,
      kind: KIND_CLASS,
      url: "#{BASE_URL}/en-US/docs/Web/JavaScript/Reference/Global_Objects/#{class_name}",
      props: props,
      methods: methods,
      classProps: class_props,
      classMethods: class_methods,
      ecma6: ecma6,
      deprecated: false,
      nonStandard: false,
      recognitionKeys: [recognition_key_for_kind(KIND_CLASS)]
    }

    if !constructor_params.nil?
      output_doc[:constructor] = {
          params: constructor_params
      }
    end

    output_doc
  end


  def parse_member_file(class_name, file_path)
    puts "Parsing file for member file #{file_path} ..."

    simple_filename = File.basename(file_path)

    md = /^((?:\w+\.)+)?(\w+)(\(.*\))?\.html$/.match(simple_filename)

    unless md
      puts "Can't match member filename: '#{simple_filename}'"
      return
    end

    kind = KIND_CLASS_PROPERTY
    qualifier = md[1]
    simple_name = md[2]
    args = md[3]

    if class_name
      if args
        kind = KIND_CLASS_METHOD
      end

      if qualifier.end_with?('.prototype.')
        if kind == KIND_CLASS_METHOD
          kind = KIND_METHOD
        else
          kind = KIND_PROPERTY
        end
        qualifier = qualifier.gsub('.prototype.', '.')
      end
    else
      kind = KIND_GLOBAL_PROPERTY
    end

    summary_html = nil
    syntax = nil
    parameters_html = nil
    return_html = nil
    description_html = nil
    errors_thrown_html = nil
    non_standard = false
    ecma6 = false
    deprecated = false

    File.open(file_path) do |f|
      doc = Nokogiri::HTML(f)

      unless class_name
        if doc.css('h1').text.include?('(')
          kind = KIND_GLOBAL_FUNCTION
        end
      end

      ecma6 = doc.css('.overheadIndicator').text().include?('ECMAScript 6')
      non_standard = !doc.css('.nonStandard').empty?
      deprecated = !doc.css('.deprecated').empty?

      summary_html = get_next_element_html(doc, '#Summary')
      description_html = get_next_element_html(doc, '#Description')

      if is_invokable_kind?(kind)
        syntax_h2 = doc.css('#Syntax').first

        if syntax_h2
          syntax = syntax_h2.next_element().text()
        end

        parameters_html = get_next_element_html(doc, '#Parameters')
        return_html = get_next_element_html(doc, '#Returns')
        errors_thrown_html = get_next_element_html(doc, '#Errors_thrown')
      end
    end

    url = "#{BASE_URL}/en-US/docs/Web/JavaScript/Reference/Global_Objects/"

    if class_name
      url = url + class_name + '/'
    end

    url += simple_name
    qualified_name = (qualifier || '') + simple_name

    output_doc = {
      _id: qualified_name,
      class: class_name,
      simpleName: simple_name,
      qualifiedName: qualified_name,
      summaryHtml: summary_html,
      ecma6: ecma6,
      nonStandard: non_standard,
      deprecated: deprecated,
      kind: kind,
      url: url,
      recognitionKeys: [recognition_key_for_kind(kind)]
    }

    if is_invokable_kind?(kind)
      output_doc[:syntax] = strip(syntax)
      output_doc[:parametersHtml] = strip(parameters_html)
      output_doc[:errorsThrownHtml] = strip(errors_thrown_html)
      output_doc[:returnValueDescriptionHtml] = strip(return_html)
    end

    output_doc[:descriptionHtml] = strip(description_html)

    puts "Done parsing file for member file #{file_path}."

    return output_doc
  end

  def update_class_doc_with_member(class_doc, member_doc)
    p = nil
    case member_doc[:kind]
      when KIND_CLASS_METHOD
        p = :classMethods
      when KIND_CLASS_PROPERTY
        p = :classProps
      when KIND_METHOD
        p = :methods
      when KIND_PROPERTY
        p = :props
      else
        raise 'Invalid kind'
    end

    m = class_doc[p].find { |doc| doc[:simpleName] == member_doc[:simpleName] }

    if m
      puts "Found member doc to update for #{member_doc[:qualifiedName]}"
      [:ecma6, :nonStandard, :deprecated].each do |name|
        m[name] = member_doc[name]
      end

      if is_invokable_kind?(member_doc[:kind])
        [:syntax, :parametersHtml, :returnValueDescriptionHtml].each do |name|
          if member_doc[name]
            m[name] = member_doc[name]
          end
        end
      end
    else
      puts "Can't find member doc to update for #{member_doc[:qualifiedName]}"

      class_doc[p] << member_doc.select do |k, v|
        [:simpleName, :summaryHtml, :ecma6, :nonStandard, :deprecated, :syntax, :parametersHtml, :returnValueDescriptionHtml, :url].include?(k)
      end
    end
  end

  def get_next_element_html(doc, selector)
    element = doc.css(selector).first

    if element
      next_element = element.next_element()
      if next_element
        return next_element.inner_html
      end
    end

    return nil
  end

  def strip(s)
    if s
      s.strip
    else
      nil
    end
  end

  def is_invokable_kind?(kind)
    kind == KIND_METHOD || kind == KIND_CLASS_METHOD || kind == KIND_GLOBAL_FUNCTION
  end

  def recognition_key_for_kind(kind)
    'com.solveforall.recognition.programming.web.javascript.globals.' + kind
  end
end

output_filename = 'javascript_docs.json'

download = false

ARGV.each do |arg|
  if arg == '-d'
    download = true
  else
    output_filename = arg
  end
end

populator = JavascriptDocPopulator.new(output_filename)

if download
  populator.download()
end

populator.populate()
system("bzip2 -kf #{output_filename}")