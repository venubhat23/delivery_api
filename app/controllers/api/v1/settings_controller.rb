module Api
  module V1
    class SettingsController < ApplicationController
      # GET /api/v1/settings
      def show
        admin_setting = AdminSetting.first

        customer = current_user.is_a?(Customer) ? current_user : nil
        referral_code = customer&.member_id || ""

        response = {
          faq: default_faq,
          contact_us: contact_details(admin_setting),
          refer_and_earn: {
            referral_code: referral_code,
            message: referral_code.present? ? "Share this code to earn rewards" : ""
          },
          delivery_preferences: delivery_preferences_for(customer),
          terms_and_conditions: admin_setting&.terms_and_conditions,
          privacy_policy: default_privacy_policy
        }

        render json: response, status: :ok
      end

      private

      def contact_details(admin_setting)
        return {} unless admin_setting
        {
          business_name: admin_setting.business_name,
          mobile: admin_setting.mobile,
          email: admin_setting.email,
          address: admin_setting.address,
          upi_qr_code: admin_setting.qr_code_path
        }
      end

      def delivery_preferences_for(customer)
        return {} unless customer
        {
          preferred_language: customer.preferred_language,
          delivery_time_preference: customer.delivery_time_preference,
          notification_method: customer.notification_method
        }
      end

      def default_faq
        [
          { q: "How do I update my address?", a: "Use the update address endpoint or contact support." },
          { q: "When are deliveries made?", a: "Deliveries are made as per your delivery time preference." }
        ]
      end

      def default_privacy_policy
        "We respect your privacy and handle your data in accordance with applicable laws."
      end
    end
  end
end