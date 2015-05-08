# encoding: utf-8

require 'debugger'
module RuboCop
  module Cop
    module Lint
      # This cop checks for interpolated literals.
      #
      # @example
      #
      #   "result is #{10}"
      class LiteralInInterpolation < Cop
        LITERALS = [:str, :dstr, :int, :float, :array,
                    :hash, :regexp, :nil, :true, :false]

        MSG = 'Literal interpolation detected.'

        def on_dstr(node)
          node.children.select { |n| n.type == :begin }.each do |begin_node|
           final_node = begin_node.children.last

            add_offense(node, :expression) if violator?(final_node)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, autocorrected_string(node))
          end
        end

        private

        def violator?(node)
          violates = true
          violates= false unless node
          violates = false if special_keyword?(node)
          violates = false unless LITERALS.include?(node.type)

          violates
        end

        def special_keyword?(node)
          # handle strings like __FILE__
          (node.type == :str && !node.loc.respond_to?(:begin)) ||
            node.loc.expression.is?('__LINE__')
        end

        def autocorrected_string(node)
          node.children.each_with_object('') do |child, string|
            source = child.loc.expression.source

            # foo => violator?
            string << (foo?(child) ? source : source[/#\{(.*)\}/, 1])
          end
        end

        def foo?(node)
          node.str_type? || !LITERALS.include?(node.children.last.type)
        end
      end
    end
  end
end
