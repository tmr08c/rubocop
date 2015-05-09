# encoding: utf-8

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
            corrector.replace(node.loc.expression, %("#{autocorrected_string(node)}"))
          end
        end

        private

        def special_keyword?(node)
          # handle strings like __FILE__
          (node.type == :str && !node.loc.respond_to?(:begin)) ||
            node.loc.expression.is?('__LINE__')
        end

        def autocorrected_string(node)
          node.children.each_with_object("") do |child, string|
            source = child.loc.expression.source

            if keep_interpolation? child
              string << source
            else
              string << source[/#\{(.*)\}/, 1]
            end
          end
        end

        def keep_interpolation?(node)
          node.str_type? || !LITERALS.include?(node.children.last.type)
        end
      end
    end
  end
end
