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

    class InvalidReferenceError < Error #:nodoc:
    end

    #
    # Class representing a Reference Object.
    # Reference are like symbolic links pointing to a particular object into the file.
    #
    class Reference
        include Origami::Object

        TOKENS = [ "(?<no>\\d+)" + WHITESPACES +  "(?<gen>\\d+)" + WHITESPACES + "R" ] #:nodoc:
        REGEXP_TOKEN = Regexp.new(TOKENS.first, Regexp::MULTILINE)
        @@regexp = Regexp.new(WHITESPACES + TOKENS.first + WHITESPACES)

        attr_accessor :refno, :refgen

        def initialize(refno, refgen)
            super()

            @refno, @refgen = refno, refgen
        end

        def self.parse(stream, _parser = nil) #:nodoc:
            offset = stream.pos

            if stream.scan(@@regexp).nil?
                raise InvalidReferenceError, "Bad reference to indirect objet format"
            end

            no = stream['no'].to_i
            gen = stream['gen'].to_i

            ref = Reference.new(no, gen)
            ref.file_offset = offset

            ref
        end

        def solve
            doc = self.document

            if doc.nil?
                raise InvalidReferenceError, "Not attached to any document"
            end

            target = doc.get_object(self)

            if target.nil? and not Origami::OPTIONS[:ignore_bad_references]
                raise InvalidReferenceError, "Cannot resolve reference : #{self}"
            end

            target or Null.new
        end

        def hash #:nodoc:
            self.to_a.hash
        end

        def <=>(ref) #:nodoc
            self.to_a <=> ref.to_a
        end

        #
        # Compares to Reference object.
        #
        def ==(ref)
            return false unless ref.is_a?(Reference)

            self.to_a == ref.to_a
        end
        alias eql? ==

        #
        # Returns a Ruby array with the object number and the generation this reference is pointing to.
        #
        def to_a
            [@refno, @refgen]
        end

        def to_s #:nodoc:
            super("#{@refno} #{@refgen} R")
        end

        #
        # Returns the referenced object value.
        #
        def value
            self.solve.value
        end
    end

end
