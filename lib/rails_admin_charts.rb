require 'lazy_high_charts/engine'
require 'rails_admin_charts/engine'

module RailsAdminCharts
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def total_records_since(from = 30.days.ago, to = Date.today)
      date_created_at = "Date(#{self.table_name}.created_at)"
      totals, before_count = self.group(date_created_at).count, self.where(date_created_at + ' < ?', from.to_date).count
      # TODO separate MySQL/Postgres approaches using ActiveRecord::Base.connection.adapter_name or check hash key is_a? String/Date
      (from.to_date..to.to_date).each_with_object([]) { |day, a| a << (a.last || before_count) + (totals[day] || totals[day.to_s] || 0) }
    end

    def delta_records_since(from = 30.days.ago, to = Date.today)
      date_created_at = "Date(#{self.table_name}.created_at)"
      deltas = self.group(date_created_at).count
      (from.to_date..to.to_date).map { |date| deltas[date] ||  deltas[date.to_s] || 0 }
    end

    # Class for condition
    def class
      #Company
      nil
    end

    def chart_form?
      false
    end

    def sym_for_condition
      nil
      #:company_id
    end

    def graph_data(from = Date.today.beginning_of_year, to = Date.today, condition = {})
      data = nil
      if condition.present?
        data = self.unscoped.where(condition).delta_records_since(from, to)
      else
        data = self.unscoped.total_records_since(from, to)
      end
        [
            {
                name: model_name.plural,
                pointInterval: 1.day * 1000,
                pointStart: from.to_time.to_i * 1000,
                data: data
            }
        ]
    end

    def xaxis
      "datetime"
    end

    def label_rotation
      "0"
    end

    def chart_type
      ""
    end
  end
end

#require 'rails_admin/config/actions'
require 'rails_admin_charts/rails_admin/config/actions/charts'
