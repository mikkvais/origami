=begin

    This file is part of Origami, PDF manipulation framework for Ruby
    Copyright (C) 2016	Guillaume Delugré.

    Origami is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Origami is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Origami.  If not, see <http://www.gnu.org/licenses/>.

=end

module Origami

    class PDF

        class InvalidHeaderError < Error #:nodoc:
        end

        #
        # Class representing a PDF Header.
        #
        class Header
            MAGIC = /%PDF-(?<major>\d+)\.(?<minor>\d+)/

            attr_accessor :major_version, :minor_version

            #
            # Creates a file header, with the given major and minor versions.
            # _major_version_:: Major PDF version, must be 1.
            # _minor_version_:: Minor PDF version, must be between 0 and 7.
            #
            def initialize(major_version = 1, minor_version = 4)
                @major_version, @minor_version = major_version, minor_version
            end

            def self.parse(stream) #:nodoc:
                unless stream.scan(MAGIC).nil?
                    maj = stream['major'].to_i
                    min = stream['minor'].to_i
                else
                    raise InvalidHeaderError, "Invalid header format : #{stream.peek(15).inspect}"
                end

                stream.skip(REGEXP_WHITESPACES)

                PDF::Header.new(maj, min)
            end

            #
            # Outputs self into PDF code.
            #
            def to_s
                "%PDF-#{@major_version}.#{@minor_version}".b + EOL
            end

            def to_sym #:nodoc:
                "#{@major_version}.#{@minor_version}".to_sym
            end

            def to_f #:nodoc:
                to_sym.to_s.to_f
            end
        end
    end

end
