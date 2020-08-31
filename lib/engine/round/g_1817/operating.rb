# frozen_string_literal: true

require_relative '../operating'
require_relative '../../step/buy_train'

module Engine
  module Round
    module G1817
      class Operating < Operating
        attr_accessor :last_player

        def setup
          @paid_loans = {}
        end

        def after_process(action)
          # Keep track of last_player for Cash Crisis
          entity = action.entity
          @last_player = entity.player
          pay_interest!(entity)
          super
        end

        def pay_interest!(entity)
          return if entity.loans.empty?
          return if @paid_loans[entity]
          return unless @steps.any? { |step| step.passed? && step.is_a?(Step::BuyTrain) }

          bank = @game.bank
          owed = @game.interest_owed(entity)
          owed_fmt = @game.format_currency(owed)

          while owed > entity.cash &&
              (loan = @game.loans[0]) &&
              entity.loans.size < @game.maximum_loans(entity)
            @game.take_loan(entity, loan)
          end

          if owed <= entity.cash
            @log << "#{entity.name} pays #{owed_fmt} interest"
            entity.spend(owed, bank)
            return
          end

          owner = entity.owner
          @game.stock_market.move(entity, 0, 0, force: true)

          transferred = ''

          if entity.cash.positive?
            transferred = ", transferring #{@game.format_currency(entity.cash)} to #{owner.name}"
            entity.spend(entity.cash, owner)
          end

          @log << "#{entity.name} cannot afford #{owed_fmt} interest and goes into liquidation#{transferred}"

          owner.spend(owed, bank, check_cash: false)
          @log << "#{owner.name} pays #{owed_fmt} interest"
        end
      end
    end
  end
end
