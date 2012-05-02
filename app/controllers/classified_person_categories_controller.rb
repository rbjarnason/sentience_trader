class ClassifiedPersonCategoriesController < ApplicationController
  # GET /classified_person_categories
  # GET /classified_person_categories.xml
  
  layout "main"
  
  def index
    @classified_person_categories = ClassifiedPersonCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classified_person_categories }
    end
  end

  # GET /classified_person_categories/1
  # GET /classified_person_categories/1.xml
  def show
    @classified_person_category = ClassifiedPersonCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classified_person_category }
    end
  end

  # GET /classified_person_categories/new
  # GET /classified_person_categories/new.xml
  def new
    @classified_person_category = ClassifiedPersonCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @classified_person_category }
    end
  end

  # GET /classified_person_categories/1/edit
  def edit
    @classified_person_category = ClassifiedPersonCategory.find(params[:id])
  end

  # POST /classified_person_categories
  # POST /classified_person_categories.xml
  def create
    @classified_person_category = ClassifiedPersonCategory.new(params[:classified_person_category])

    respond_to do |format|
      if @classified_person_category.save
        flash[:notice] = 'ClassifiedPersonCategory was successfully created.'
        format.html { redirect_to(@classified_person_category) }
        format.xml  { render :xml => @classified_person_category, :status => :created, :location => @classified_person_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @classified_person_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classified_person_categories/1
  # PUT /classified_person_categories/1.xml
  def update
    @classified_person_category = ClassifiedPersonCategory.find(params[:id])

    respond_to do |format|
      if @classified_person_category.update_attributes(params[:classified_person_category])
        flash[:notice] = 'ClassifiedPersonCategory was successfully updated.'
        format.html { redirect_to(@classified_person_category) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classified_person_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classified_person_categories/1
  # DELETE /classified_person_categories/1.xml
  def destroy
    @classified_person_category = ClassifiedPersonCategory.find(params[:id])
    @classified_person_category.destroy

    respond_to do |format|
      format.html { redirect_to(classified_person_categories_url) }
      format.xml  { head :ok }
    end
  end
end
