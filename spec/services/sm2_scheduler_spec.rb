# frozen_string_literal: true

# T046 — SM2Scheduler spec
#
# Covers:
#   - All four ratings: again, hard, good, easy
#   - Progressive interval growth over multiple reviews
#   - Ease factor clamping (1.3 lower bound, 2.5 upper bound)
#   - next_review_date calculation relative to today
require 'rails_helper'

RSpec.describe SM2Scheduler do
  # Minimal schedule struct used to feed the scheduler
  let(:new_schedule) do
    { interval_days: 0, ease_factor: 2.5, review_count: 0 }
  end

  describe '.call' do
    subject(:result) { described_class.call(schedule: schedule, rating: rating) }

    context 'with a brand-new card (interval_days: 0, ease_factor: 2.5)' do
      let(:schedule) { new_schedule }

      context 'when rated :again' do
        let(:rating) { :again }

        it 'sets interval_days to 0 (same day)' do
          expect(result[:interval_days]).to eq(0)
        end

        it 'decreases ease_factor by 0.20' do
          expect(result[:ease_factor]).to be_within(0.01).of(2.30)
        end

        it 'sets next_review_date to today' do
          expect(result[:next_review_date]).to eq(Time.zone.today)
        end

        it 'increments review_count' do
          expect(result[:review_count]).to eq(1)
        end
      end

      context 'when rated :hard' do
        let(:rating) { :hard }

        it 'sets interval_days to 1 (minimum)' do
          expect(result[:interval_days]).to eq(1)
        end

        it 'decreases ease_factor by 0.15' do
          expect(result[:ease_factor]).to be_within(0.01).of(2.35)
        end

        it 'sets next_review_date to tomorrow' do
          expect(result[:next_review_date]).to eq(Time.zone.today + 1)
        end
      end

      context 'when rated :good' do
        let(:rating) { :good }

        it 'sets interval_days to 1' do
          expect(result[:interval_days]).to eq(1)
        end

        it 'keeps ease_factor unchanged' do
          expect(result[:ease_factor]).to be_within(0.01).of(2.5)
        end

        it 'sets next_review_date to tomorrow' do
          expect(result[:next_review_date]).to eq(Time.zone.today + 1)
        end
      end

      context 'when rated :easy' do
        let(:rating) { :easy }

        it 'sets interval_days to 4' do
          expect(result[:interval_days]).to eq(4)
        end

        it 'increases ease_factor by 0.15 (capped at 2.5)' do
          expect(result[:ease_factor]).to be_within(0.01).of(2.5)
        end

        it 'sets next_review_date 4 days from today' do
          expect(result[:next_review_date]).to eq(Time.zone.today + 4)
        end
      end
    end

    context 'with a previously reviewed card (interval_days: 4, ease_factor: 2.5)' do
      let(:schedule) { { interval_days: 4, ease_factor: 2.5, review_count: 2 } }

      context 'when rated :good' do
        let(:rating) { :good }

        it 'multiplies interval by ease_factor' do
          expect(result[:interval_days]).to eq((4 * 2.5).ceil)
        end

        it 'keeps ease_factor unchanged' do
          expect(result[:ease_factor]).to be_within(0.01).of(2.5)
        end
      end

      context 'when rated :easy' do
        let(:rating) { :easy }

        it 'multiplies interval by ease_factor * 1.3' do
          expect(result[:interval_days]).to eq((4 * 2.5 * 1.3).ceil)
        end

        it 'increases ease_factor by 0.15 up to max 2.5' do
          expect(result[:ease_factor]).to be_within(0.01).of(2.5)
        end
      end

      context 'when rated :again' do
        let(:rating) { :again }

        it 'resets interval_days to 0 (same day)' do
          expect(result[:interval_days]).to eq(0)
        end

        it 'decreases ease_factor by 0.20' do
          expect(result[:ease_factor]).to be_within(0.01).of(2.30)
        end
      end
    end

    context 'with ease factor near the lower bound (1.35)' do
      let(:schedule) { { interval_days: 1, ease_factor: 1.35, review_count: 5 } }

      context 'when rated :again (would push below 1.3)' do
        let(:rating) { :again }

        it 'clamps ease_factor to minimum 1.3' do
          expect(result[:ease_factor]).to be >= 1.3
        end
      end

      context 'when rated :hard (would push below 1.3)' do
        let(:rating) { :hard }

        it 'clamps ease_factor to minimum 1.3' do
          expect(result[:ease_factor]).to be >= 1.3
        end
      end
    end

    context 'with ease factor near the upper bound (2.45)' do
      let(:schedule) { { interval_days: 10, ease_factor: 2.45, review_count: 3 } }

      context 'when rated :easy (would push above 2.5)' do
        let(:rating) { :easy }

        it 'clamps ease_factor to maximum 2.5' do
          expect(result[:ease_factor]).to be <= 2.5
        end
      end
    end

    context 'with progressive interval growth across multiple good ratings' do
      it 'grows interval exponentially with successive :good ratings' do
        schedule = { interval_days: 0, ease_factor: 2.5, review_count: 0 }

        %i[good good good].each do |rating|
          schedule = described_class.call(schedule: schedule, rating: rating)
        end

        expect(schedule[:interval_days]).to be > 3
      end
    end
  end
end
