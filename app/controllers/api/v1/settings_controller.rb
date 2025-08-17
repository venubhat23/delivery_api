module Api
  module V1
    class SettingsController < ApplicationController
      before_action :authenticate_request

      # GET /api/v1/settings
      def index
        admin = AdminSetting.first
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer

        faq_summary = {
          categories: Faq.active.for_locale(params[:locale]).group(:category).count.map { |cat, cnt| { title: cat, count: cnt } },
        }

        cms = build_cms_metadata(params[:locale])
        referral = build_referral(customer)
        delivery_preferences = build_delivery_preferences(customer)
        contact = build_contact(admin)

        render json: {
          user: user_summary(customer),
          deliveryPreferences: delivery_preferences,
          referral: referral,
          faq: faq_summary,
          cms: cms,
          contact: contact
        }, status: :ok
      end

      # GET /api/v1/settings/faq
      def faq
        faqs = Faq.active.for_locale(params[:locale]).ordered
        render json: faqs.as_json(only: [:id, :category, :question, :answer, :locale, :sort_order]), status: :ok
      end

      # GET /api/v1/settings/cms/terms-of-service
      def terms
        page = CmsPage.published.for_slug('terms-of-service').for_locale(params[:locale]).order(published_at: :desc).first
        return render json: { error: 'Terms not found' }, status: :not_found unless page
        render json: page.as_json(only: [:slug, :version, :title, :content, :locale, :published_at]), status: :ok
      end

      # GET /api/v1/settings/cms/privacy-policy
      def privacy
        page = CmsPage.published.for_slug('privacy-policy').for_locale(params[:locale]).order(published_at: :desc).first
        return render json: { error: 'Privacy policy not found' }, status: :not_found unless page
        render json: page.as_json(only: [:slug, :version, :title, :content, :locale, :published_at]), status: :ok
      end

      # GET /api/v1/settings/referral
      def referral
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        render json: build_referral(customer), status: :ok
      end

      # GET /api/v1/settings/delivery-preferences
      def delivery_preferences
        customer = current_user.is_a?(Customer) ? current_user : current_user&.customer
        render json: build_delivery_preferences(customer), status: :ok
      end

      # POST /api/v1/settings/contact
      def contact
        ticket = SupportTicket.new(
          customer: current_user.is_a?(Customer) ? current_user : current_user&.customer,
          subject: params[:subject],
          message: params[:message],
          channel: 'app'
        )

        if ticket.save
          render json: { message: 'Support request submitted', ticket_id: ticket.id }, status: :created
        else
          render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def build_cms_metadata(locale)
        terms = CmsPage.published.for_slug('terms-of-service').for_locale(locale).order(published_at: :desc).first
        privacy = CmsPage.published.for_slug('privacy-policy').for_locale(locale).order(published_at: :desc).first
        {
          termsOfService: terms ? { version: terms.version, lastUpdated: terms.published_at, url: nil } : nil,
          privacyPolicy: privacy ? { version: privacy.version, lastUpdated: privacy.published_at, url: nil } : nil
        }
      end

      def build_referral(customer)
        return nil unless customer
        ref = ReferralCode.find_by(customer_id: customer.id)
        if ref.nil?
          # Generate a simple unique code if not present
          code = loop do
            candidate = SecureRandom.alphanumeric(8).upcase
            break candidate unless ReferralCode.exists?(code: candidate)
          end
          ref = ReferralCode.create!(customer_id: customer.id, code: code, share_url_slug: code)
        end
        {
          code: ref.code,
          shareUrl: ref.share_url(request.base_url),
          creditsEarned: ref.total_credits,
          referralsCount: ref.total_referrals
        }
      end

      def build_delivery_preferences(customer)
        return nil unless customer
        {
          timeWindow: { start: nil, end: nil },
          daysOfWeek: nil,
          skipWeekends: nil,
          notes: nil,
          deliveryTimePreference: customer.delivery_time_preference
        }
      end

      def build_contact(admin)
        {
          email: admin&.email,
          phone: admin&.mobile
        }
      end

      def user_summary(customer)
        if current_user.is_a?(Customer)
          { id: current_user.id, name: current_user.name }
        elsif current_user.is_a?(User) && customer
          { id: customer.id, name: customer.name }
        else
          { id: current_user.id, name: current_user.name }
        end
      end
    end
  end
end