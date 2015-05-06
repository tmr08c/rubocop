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
            next unless final_node
            next if special_keyword?(final_node)
            next unless LITERALS.include?(final_node.type)

            add_offense(node, :expression)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            # debugger
            node.children.each_with_object('') do |child, string|
              if child.str_type?
                string << child.loc.expression.source
              else
                string << child.loc.expression.source[/#\{(.*)\}/, 1]
              end
            end
            puts string
          end
        end

        private

        def special_keyword?(node)
          # handle strings like __FILE__
          (node.type == :str && !node.loc.respond_to?(:begin)) ||
            node.loc.expression.is?('__LINE__')
        end
      end
    end
  end
end
