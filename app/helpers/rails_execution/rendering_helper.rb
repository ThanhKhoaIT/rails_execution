module RailsExecution
  module RenderingHelper
    AVATAR_CLASS = 'bd-placeholder-img flex-shrink-0 me-2 rounded'
    TRUNCATE_FILE_NAME_LENGTH = 20

    def render_user_info(user, avatar_size: '40x40')
      content_tag :div, class: 'user-info' do
        concat render_owner_avatar(user, size: avatar_size)
        concat render_owner_name(user)
      end
    end

    def render_owner_avatar(owner, size: '32x32')
      return image_tag(asset_path('executions/robot.png'), size: size, class: AVATAR_CLASS) if owner.blank?

      avatar_url = RailsExecution.configuration.owner_avatar.call(owner)
      return nil if avatar_url.blank?

      image_tag avatar_url, size: size, class: AVATAR_CLASS
    end

    def render_owner_name(owner)
      return 'System' if owner.blank?
      return nil if RailsExecution.configuration.owner_name_method.blank?

      content_tag :span, owner.public_send(RailsExecution.configuration.owner_name_method)
    end

    def render_notification_message(mode, message)
      case mode
      when 'alert'
        content_tag :div, class: 'alert alert-warning align-items-center' do
          concat content_tag(:i, nil, class: 'bi bi-x-octagon mr-2')
          concat content_tag(:span, message, class: 'ms-2')
        end
      when 'notice'
        content_tag :div, class: 'alert alert-success align-items-center' do
          concat content_tag(:i, nil, class: 'bi bi-check-circle mr-2')
          concat content_tag(:span, message, class: 'ms-2')
        end
      end
    end

    def render_label(task_label)
      content_tag :div do
        concat content_tag :i, '', class: "bi bi-tag label-colors lc-#{task_label.color} bg-none"
        concat content_tag :span, task_label.name, class: "badge rounded-pill mx-1 label-colors lc-#{task_label.color}"
      end
    end

    def render_task_labels(task)
      # to_a and sort_by instead of .order for avoid N+1 query to sort task labels for each task
      task.labels.to_a.sort_by(&:name).reduce(''.html_safe) do |result, label|
        case label.name
        when 'repeat'
          result + content_tag(:span, "repeat: #{task.repeat_mode}", class: "badge rounded-pill mx-1 label-tag label-colors lc-#{label.color}", data: { id: label.id })
        when 'scheduled'
          result + content_tag(:span, 'scheduled', class: "badge rounded-pill mx-1 label-tag label-colors lc-#{label.color}", data: { id: label.id })
        else
          result + content_tag(:span, label.name, class: "badge rounded-pill mx-1 label-tag label-colors lc-#{label.color}", data: { id: label.id })
        end
      end
    end

    def task_reviewed_status(task)
      @task_reviewed_status ||= {}
      @task_reviewed_status[task] ||= task.task_reviews.find_by(owner_id: current_owner&.id)&.status&.inquiry
    end

    def re_page_actions(&block)
      content_for :page_actions do
        content_tag :span, class: 'ms-2' do
          capture(&block)
        end
      end
    end

    def re_card_content(id: nil, &block)
      content_tag :div, id: id, class: 'my-3 p-3 bg-body rounded shadow-sm' do
        capture(&block)
      end
    end

    def re_render_paging(relation)
      render partial: 'rails_execution/shared/paging', locals: { page: relation.re_current_page, total_pages: relation.re_total_pages }
    end

    def re_attachment_file_acceptable_types
      ::RailsExecution.configuration.acceptable_file_types.keys.join(',')
    end

    def re_get_file_name(url)
      URI(url).path.split('/').last&.truncate(TRUNCATE_FILE_NAME_LENGTH)
    end

    def re_badge_color(status)
      color = status_to_color(status.to_s.downcase.to_sym)
      content_tag :small, status.to_s.titleize, class: "fw-light badge rounded-pill text-bg-#{color}"
    end

    private

    def status_to_color(text)
      {
        bad: 'danger',
        good: 'success',
        closed: 'danger',
        created: 'primary',
        rejected: 'danger',
        approved: 'success',
        reviewing: 'secondary',
        processing: 'warning',
        completed: 'success',
      }[text] || 'secondary'
    end

  end
end
