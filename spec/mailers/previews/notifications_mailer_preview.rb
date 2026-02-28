# Preview all emails at http://localhost:3000/rails/mailers/notifications_mailer
class NotificationsMailerPreview < ActionMailer::Preview
  def notify_about_payment
    NotificationsMailer.with(transaction: EripTransaction.first).notify_about_payment
  end

  def notify_about_last_hour
    NotificationsMailer.with(user: User.first).notify_about_last_hour
  end
end
