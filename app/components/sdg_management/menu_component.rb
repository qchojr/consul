class SDGManagement::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def links
      [goals_link, *relatable_links]
    end

    def goals_link
      [t("sdg_management.menu.sdg_content"), sdg_management_goals_path, sdg?, class: "goals-link"]
    end

    def relatable_links
      SDG::Related::RELATABLE_TYPES.map do |type|
        [
          t("sdg_management.menu.#{table_name(type)}"),
          relatable_type_path(type),
          controller_name == "relations" && params[:relatable_type] == type.tableize,
          class: "#{table_name(type).tr("_", "-")}-link"
        ]
      end
    end

    def sdg?
      controller_name == "goals" || controller_name == "targets"
    end

    def relatable_type_path(type)
      send("sdg_management_#{table_name(type)}_path")
    end

    def table_name(type)
      type.constantize.table_name
    end
end
