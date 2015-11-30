# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

module TwitterCldr
  module Parsers
    class UnicodeRegexParser

      # Can exist inside and outside of character classes
      class CharacterSet < Component

        include TwitterCldr::Shared

        attr_reader :property_name, :property_value

        def initialize(text)
          if (name_parts = text.split("=")).size == 2
            @property_name, @property_value = name_parts
          else
            @property_value = text
          end
        end

        def to_regexp_str
          set_to_regex(to_set)
        end

        def to_set
          codepoints.subtract(
            TwitterCldr::Shared::UnicodeRegex.invalid_regexp_chars
          )
        end

        def codepoints
          code_points = CodePoint.code_points_for_property(
            *normalized_property
          )

          if code_points.empty?
            raise UnicodeRegexParserError,
              "Couldn't find property '#{property_name}' containing "\
              "property value '#{property_value}'"
          end
        end

        private

        def normalized_property
          @normalized_property ||= begin
            property_name_candidates.each do |property_name|
              prop_name, prop_value = normalized_property_value(
                property_name, property_value_candidates
              )

              if prop_name
                return [prop_name, prop_value]
              end
            end

            [nil, nil]
          end
        end

        def normalized_property_value(property_name, property_value_candidates)
          property_value_candidates.each do |property_value|
            prop_name, prop_value = CodePoint.properties.normalize(
              property_name, property_value
            )

            if prop_name
              return [prop_name, prop_value]
            end
          end

          [nil, nil]
        end

        def property_value_candidates
          if property_name && property_value
            [property_value]
          else
            [property_value, nil]
          end
        end

      end
    end
  end
end
