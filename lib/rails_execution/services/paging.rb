module RailsExecution
  module Services
    class Paging

      def initialize(per_page: nil, page: 1)
        @per_page = per_page.presence || RailsExecution.configuration.per_page.to_i
        @per_page = [@per_page, 1].max
        @page = [page.to_i, 1].max
      end

      def call(relation)
        total_count = relation.count
        relation = relation.offset(offset_paging).limit(per_page)
        inject_paging_data(relation, total_count)
        return relation
      end

      private

      attr_reader :per_page
      attr_reader :page

      def offset_paging
        page * per_page - per_page
      end

      def inject_paging_data(relation, total_count)
        current_page, total_pages = @page, (total_count.to_f / @per_page).ceil
        relation.define_singleton_method(:re_current_page) { current_page }
        relation.define_singleton_method(:re_total_pages) { total_pages }
      end

    end
  end
end
