# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1822
      module Step
        class IssueShares < Engine::Step::IssueShares
          def actions(entity)
            actions = super
            if !ability_choices(entity).empty? || (actions.empty? && ability_lancashire_union_railway?(entity))
              actions << 'ability_choose' unless actions.include?('ability_choose')
            end
            actions << 'pass' if !actions.empty? && !actions.include?('pass')
            actions
          end

          def ability_choices(entity)
            return {} unless entity.company?

            @game.company_choices(entity, :issue)
          end

          def ability_lancashire_union_railway?(entity)
            return unless entity.corporation?

            # Special case if corporation is sold out and have LUR. Make sure we are stopping on this step
            entity.companies.any? { |c| c.id == @game.class::COMPANY_LUR }
          end

          def process_ability_choose(action)
            @game.company_made_choice(action.entity, action.choice, :issue)
          end

          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)
            pass!
          end
        end
      end
    end
  end
end
