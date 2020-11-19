require "i18n/exceptions"
require "action_view/helpers/tag_helper"

module ActionView
  module Helpers
    module TranslationHelper
      include TagHelper

      def t(key, options = {})
        current_locale = options[:locale].presence || I18n.locale
        translation = I18nContent.for_key_and_locale(key: key, locale: current_locale)

        if translation.present?
          translation % options
        else
          translate(key, options)
        end
      end
    end
  end
end
