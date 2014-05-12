## The MIT License (MIT)
##
## Copyright (c) 2014-2024
## Savin Max <mafei.198@gmail.com>
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.


desc "Generate API"

COMMON_TYPE = ['string', 'integer', 'float', 'short', 'char', 'boolean']

def common_protocol(field_type, variable, code)
  case field_type
  when 'string'
    "utils_protocol:#{code}_string(#{variable})"
  when 'integer'
    "utils_protocol:#{code}_integer(#{variable})"
  when 'float'
    "utils_protocol:#{code}_float(#{variable})"
  when 'short'
    "utils_protocol:#{code}_short(#{variable})"
  when 'char'
    "utils_protocol:#{code}_char(#{variable})"
  when 'boolean'
    "utils_protocol:#{code}_boolean(#{variable})"
  end
end

def common_decode_with_index(field_type, variable, field_idx)
  case field_type
  when 'string'
    "{#{variable}, Bin#{field_idx+1}} = utils_protocol:decode_string(Bin#{field_idx})"
  when 'integer'
    "{#{variable}, Bin#{field_idx+1}} = utils_protocol:decode_integer(Bin#{field_idx})"
  when 'float'
    "{#{variable}, Bin#{field_idx+1}} = utils_protocol:decode_float(Bin#{field_idx})"
  when 'short'
    "{#{variable}, Bin#{field_idx+1}} = utils_protocol:decode_short(Bin#{field_idx})"
  when 'char'
    "{#{variable}, Bin#{field_idx+1}} = utils_protocol:decode_char(Bin#{field_idx})"
  when 'boolean'
    "{#{variable}, Bin#{field_idx+1}} = utils_protocol:decode_boolean(Bin#{field_idx})"
  end
end

task :generate_api => :environment do
  routes = "#{FRAMEWORK_ROOT_DIR}/app/api/routes.yml"
  extension_types = "#{FRAMEWORK_ROOT_DIR}/app/api/protocol/extension_types.yml"
  `mkdir -p #{FRAMEWORK_ROOT_DIR}/app/generates`
  routes_path   = "#{FRAMEWORK_ROOT_DIR}/app/generates/routes.erl"
  encoder_path  = "#{FRAMEWORK_ROOT_DIR}/app/generates/api_encoder.erl"
  decoder_path  = "#{FRAMEWORK_ROOT_DIR}/app/generates/api_decoder.erl"
  protocol_path = "#{FRAMEWORK_ROOT_DIR}/app/generates/api_protocol.erl"
  routes = YAML.load_file(routes)
  extension_types = YAML.load_file(extension_types)

  header = ""
  header << "%%%===================================================================\n"
  header << "%%% Generated by generate_api.rb #{Time.now}\n"
  header << "%%%==================================================================="

  routes_content = %Q{#{header}
-module(routes).
-export([route/1]).

}

  encoder_content = %Q{#{header}
-module(api_encoder).
-export([encode/2, encode_protocol/2]).

encode(ProtocolName, Value) ->
    ProtocolId = api_protocol:protocol_id(ProtocolName),
    EncodedValue = encode_protocol(ProtocolName, Value),
    list_to_binary([utils_protocol:encode_short(ProtocolId), EncodedValue]).
}

  decoder_content = %Q{#{header}
-module(api_decoder).
-export([decode/1, decode_protocol/2]).
-include("include/protocol.hrl").

decode(<<ProtocolId:?SHORT, Data/binary>>) ->
    ProtocolName = api_protocol:protocol_name(ProtocolId),
    decode_protocol(ProtocolName, Data).

}

  protocol_content = %Q{#{header}
-module(api_protocol).
-export([protocol_id/1, protocol_name/1]).

}

  size = routes.size
  extension_type_keys = extension_types.keys
  routes.each_with_index do |packet, idx|
    path, extension_type_key = packet
    symbol = (size - 1 == idx ? '.' : ';')

    controller, action = path.split('#')
    protocol_id = extension_type_keys.index(extension_type_key)
    if protocol_id.blank?
      msg = "Routes or ExtentionTypes definition error! \n"
      msg << "Can't match '#{extension_type_key}' in extension_types.yml."
      raise msg
    end
    routes_content << "route(#{protocol_id}) ->\n"
    routes_content << "    {#{controller}, #{action}};\n"
  end

  name_mapped = []
  id_mapped = []
  extension_type_keys.each_with_index do |name, id|
    name_mapped << "{#{name}, #{id}}"
    id_mapped << "{#{id}, #{name}}"
  end

  name_mapped = name_mapped.join(",\n" + " " * 22)
  id_mapped = id_mapped.join(",\n" + " " * 20)
  protocol_content << "-define(NAME_MAPPED, [#{name_mapped}]).\n"
  protocol_content << "\n"
  protocol_content << "-define(ID_MAPPED, [#{id_mapped}]).\n"
  protocol_content << "\n"
  protocol_content << "protocol_id(Name) -> \n"
  protocol_content << "    proplists:get_value(Name, ?NAME_MAPPED).\n"
  protocol_content << "\n"
  protocol_content << "protocol_name(Id) -> \n"
  protocol_content << "    proplists:get_value(Id, ?ID_MAPPED).\n"

  size = extension_types.size
  extension_types.each_with_index do |packet, idx|
    extension_type, fields_definition = packet
    symbol = (size - 1 == idx ? '.' : ';')
    list = []
    decode_list = []
    fields_definition and fields_definition.each_with_index do |field_definition, field_idx|
      field, field_type = field_definition
      if COMMON_TYPE.include?(field_type)
        list << common_protocol(field_type, field.camelcase, 'encode')
        decode_list << common_decode_with_index(field_type, field.camelcase, field_idx)
      elsif extension_types.keys.include?(field_type)
        list << "encode_protocol(#{field_type}, #{field.camelcase})"
        decode_list << "{#{field.camelcase}, Bin#{field_idx+1}} = api_decoder:decode_protocol(#{field_type}, Bin#{field_idx})"
      elsif field_type.index("array-") == 0
        _type, element_name = field_type.split('-')
        if COMMON_TYPE.include?(element_name)
          list << "utils_protocol:encode_array(#{field.camelcase}, fun(Item) -> #{common_protocol(element_name, 'Item', 'encode')} end)"
          decode_list << "{#{field.camelcase}, Bin#{field_idx+1}} = utils_protocol:decode_array(Bin#{field_idx}, fun(Data) -> #{common_protocol(element_name, 'Data', 'decode')} end)"
        else
          list << "utils_protocol:encode_array(#{field.camelcase}, fun(Item) -> api_encoder:encode_protocol(#{element_name}, Item) end)"
          decode_list << "{#{field.camelcase}, Bin#{field_idx+1}} = utils_protocol:decode_array(Bin#{field_idx}, fun(Data) -> api_decoder:decode_protocol(#{element_name}, Data) end)"
        end
      else
        raise "Wrong Data Type: #{field_type}"
      end
    end

    fields_definition and variables = fields_definition.keys.map(&:camelcase)
    if variables
      encoder_content << "encode_protocol(#{extension_type}, Value) ->\n"
      encoder_content << "    {#{variables.join(', ')}} = Value,\n"
      encoder_content << "    DataList = [\n"
      encoder_content << %Q{    #{list.join(",\n        ")}\n}
      encoder_content << "    ],\n"
      encoder_content << "    list_to_binary(DataList)#{symbol}\n"

      decoder_content << "decode_protocol(#{extension_type}, Bin0) ->\n"
      decoder_content << "    #{decode_list.join(",\n    ")},\n"
      fields_amount = fields_definition.keys.size
      decoder_content << %Q{    {[#{fields_definition.keys.map{|field| "{#{field}, #{field.camelcase}}"}.join(", ")}], Bin#{fields_amount}}#{symbol}\n}
    else
      encoder_content << "encode_protocol(#{extension_type}, _Value) ->\n"
      encoder_content << "    <<>>#{symbol}\n"

      decoder_content << "decode_protocol(#{extension_type}, _Bin0) ->\n"
      decoder_content << "    {[], <<>>}#{symbol}\n"
    end
  end

  routes_content << "route(UnmatchedProtocol) ->\n"
  routes_content << %Q{    Msg = list_to_binary(io_lib:format("Request Protocol[~p] Not Found!", [UnmatchedProtocol])),\n}
  routes_content << "    {error, Msg}.\n"

  File.open(routes_path, 'w'){|io| io.write routes_content}
  File.open(encoder_path, 'w'){|io| io.write encoder_content}
  File.open(decoder_path, 'w'){|io| io.write decoder_content}
  File.open(protocol_path, 'w'){|io| io.write protocol_content}
end
