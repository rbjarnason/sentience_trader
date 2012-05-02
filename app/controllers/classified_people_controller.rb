class ClassifiedPeopleController < ApplicationController
  layout "main"

  # GET /classified_people
  # GET /classified_people.xml
  def index
    @classified_people = ClassifiedPerson.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classified_people }
    end
  end

  def classify
    if request.post?
      info("in post")
      ClassifiedPerson.transaction do
        params.each do |pa|
          next if pa[1]==nil or pa[1]==""
          p = pa[0]
          cat_id = pa[1].to_i
          if p.class.to_s == "String" and p.length>16 and p[0..16]=="classified_person"
            id = (p.split("|")[1]).to_i
            info(id)
            if ClassifiedPerson.exists?(id)
              person = ClassifiedPerson.find(id)
              person.classified_person_category_id = cat_id
              info(person.inspect)
              person.save
            end
          end
        end
      end
    end
    @classified_people = ClassifiedPerson.find(:all, :conditions=>"classified_person_category_id IS NULL", :order=>"created_at DESC")
    @classified_categories = ClassifiedPersonCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classified_people }
    end
  end


  # GET /classified_people/1
  # GET /classified_people/1.xml
  def show
    @classified_person = ClassifiedPerson.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classified_person }
    end
  end

  # GET /classified_people/new
  # GET /classified_people/new.xml
  def new
    @classified_person = ClassifiedPerson.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @classified_person }
    end
  end

  # GET /classified_people/1/edit
  def edit
    @classified_person = ClassifiedPerson.find(params[:id])
  end

  # POST /classified_people
  # POST /classified_people.xml
  def create
    @classified_person = ClassifiedPerson.new(params[:classified_person])

    respond_to do |format|
      if @classified_person.save
        flash[:notice] = 'ClassifiedPerson was successfully created.'
        format.html { redirect_to(@classified_person) }
        format.xml  { render :xml => @classified_person, :status => :created, :location => @classified_person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @classified_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classified_people/1
  # PUT /classified_people/1.xml
  def update
    @classified_person = ClassifiedPerson.find(params[:id])

    respond_to do |format|
      if @classified_person.update_attributes(params[:classified_person])
        flash[:notice] = 'ClassifiedPerson was successfully updated.'
        format.html { redirect_to(@classified_person) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classified_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classified_people/1
  # DELETE /classified_people/1.xml
  def destroy
    @classified_person = ClassifiedPerson.find(params[:id])
    @classified_person.destroy

    respond_to do |format|
      format.html { redirect_to(classified_people_url) }
      format.xml  { head :ok }
    end
  end
end
