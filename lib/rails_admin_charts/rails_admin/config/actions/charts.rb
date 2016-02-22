module RailsAdmin
  module Config
    module Actions
      class Charts < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :collection? do
          true
        end

        register_instance_option :visible do
          bindings[:abstract_model].model < RailsAdminCharts
        end

        register_instance_option :http_methods do
          [:get, :post, :delete]
        end

        register_instance_option :controller do
          proc do
            if params["chart_form"].present?
              data = @abstract_model.model.graph_data(params[:chart_form][:from],
                                                      params[:chart_form][:to],
                                                      @abstract_model.model.sym_for_condition => params[:chart_form][:condition])
              render partial: "chart", formats: [:js], locals: {data: data}
            else
              render action: @action.template_name
            end
          end
        end

        register_instance_option :pjax? do
          false
        end

        register_instance_option :link_icon do
          'icon-bar-chart fa fa-bar-chart-o'
        end
      end
    end
  end
end