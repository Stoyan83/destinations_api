module Paginatable
  extend ActiveSupport::Concern

  def paginate(scope, page: params[:page], per_page: params[:per_page])
    page_number = (page || 1).to_i
    per_page_number = (per_page || 10).to_i

    paginated = scope.page(page_number).per(per_page_number)

    {
      data: paginated,
      meta: {
        current_page: paginated.current_page,
        per_page: paginated.limit_value,
        total_pages: paginated.total_pages,
        total_records: paginated.total_count
      }
    }
  end
end