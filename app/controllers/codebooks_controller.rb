class CodebooksController < ApplicationController

  def index
    @contexts = Question::QUESTIONS
  end

  def show
    @context = params[:id].gsub("class", "klass")
    @question = Question.from(@context)
    @context_key = @question.context

    # Support the previous/next navigation controls

    sections = Question::QUESTIONS.keys.map(&:to_s)
    previous_index = (sections.index(@question.key) - 1)
    next_index = (sections.index(@question.key) + 1) % sections.length
    @section_name = @question.label
    @previous_section = sections[previous_index]
    @next_section = sections[next_index]

    if @question.identity_field?
      # Identity fields have associated Identity objects.
      @frequencies = Identity.histogram(@context)
      @frequencies_by_keys = @frequencies.sort{|a, b| a[0] <=> b[0]}
      @frequencies_by_values = @frequencies.sort{|a, b| a[1] <=> b[1]}
    elsif @question.experience_field?
      # Experience fields have associated Code and Category objects.
      @frequencies = Code.histogram(@context)
      @frequencies_by_keys = @frequencies.sort{|a, b| a[0] <=> b[0]}
      @frequencies_by_values = @frequencies.sort{|a, b| a[1] <=> b[1]}
      @categories_histogram = Category.histogram(@context)
      @total_codes = @categories_histogram.values.sum
      Rails.logger.info("!!! params[:id] = #{params[:id]}")
      @codes = Code.where(context: params[:id].gsub("klass", "class").gsub("_exp", "").gsub("_", "-"))
    end

  end

end
