module RailsExecution
  class Paging

    def initialize(per_page: nil, page: 1)
      @per_page = per_page.presence || RailsExecution.configuration.per_page.to_i
      @per_page = [@per_page, 1].max
      @page = [page.to_i, 1].max
    end

    def call(relation)
      relation.offset(offset_paging).limit(per_page)
    end

    private

    attr_reader :per_page
    attr_reader :page

    def offset_paging
      page * per_page - per_page
    end

  end
end
