require 'rails_helper'

describe NotificationsService do
  before do
    allow(Setting).to receive(:[]).with('mailer_from').and_return('info@hackerspace.by')
    allow(Setting).to receive(:[]).with('test_notifications_email').and_return(nil)
    allow(Setting).to receive(:[]).with('mailer_user').and_return(nil)
  end

  let(:notified_emails) { ActionMailer::Base.deliveries.map(&:to).flatten }

  describe '.notify_expiring' do
    let!(:user_without_payment) { create :user }
    let!(:user_with_outdated_payment) { create :user, :with_outdated_payment   }
    let!(:user_expires_in_2_days) { create :user, :expires_in_2_days   }
    let!(:user_with_valid_payment) { create :user, :with_valid_payment }
    let!(:suspended_user) { create :user, :suspended, :with_outdated_payment }

    it 'sends notification email to expiring users only' do
      described_class.notify_expiring

      expect(notified_emails).not_to include(user_without_payment.email)
      expect(notified_emails).not_to include(user_with_valid_payment.email)
      expect(notified_emails).not_to include(suspended_user.email)
      expect(notified_emails).to include(user_expires_in_2_days.email)
    end
  end

  describe '.notify_last_hour' do
    let!(:user_without_payment) { create :user }
    let!(:user_with_outdated_payment) { create :user, :with_outdated_payment }
    let!(:user_expires_today) { create :user, :expires_today }
    let!(:user_with_valid_payment) { create :user, :with_valid_payment }
    let!(:suspended_user) { create :user, :suspended, :expires_today }

    it 'sends notification email to users expiring today' do
      described_class.notify_last_hour

      expect(notified_emails).to include(user_expires_today.email)
    end

    it 'does not send email to user with valid payment' do
      described_class.notify_last_hour

      expect(notified_emails).not_to include(user_with_valid_payment.email)
    end

    it 'does not send email to user without payments' do
      described_class.notify_last_hour

      expect(notified_emails).not_to include(user_without_payment.email)
    end

    it 'does not send email to suspended user' do
      described_class.notify_last_hour

      expect(notified_emails).not_to include(suspended_user.email)
    end

    it 'does not send email to user with outdated payment' do
      described_class.notify_last_hour

      expect(notified_emails).not_to include(user_with_outdated_payment.email)
    end
  end
end
