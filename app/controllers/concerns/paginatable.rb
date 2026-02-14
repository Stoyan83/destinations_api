module Paginatable
  extend ActiveSupport::Concern

  def paginate(scope, page: params[:page], per_page: params[:per_page])
    paginated = scope.page(page).per(per_page)

    {
      data: paginated,
      meta: {
        current_page:  paginated.current_page,
        per_page:      paginated.limit_value,
        total_pages:   paginated.total_pages,
        total_records: paginated.total_count
      }
    }
  end
end
