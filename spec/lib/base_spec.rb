describe Base::Obj do 

  subject(:base) do 
      Base::Obj.new('test_obj')
  end

  context "when marshalled to json" do 
    subject(:json) { base.to_json } 
    it 'is properly marshalled to json' do
        #pp json
        expect(json).to include("\"^o\":\"Base::Obj\"")
    end
    
    it 'contains the proper variables' do 
       expect(json).to include("\"name\":\"test_obj\"") 
    end
  end

  context "when restored from json" do 
      subject(:restored) { Base::Obj.load_json(base.to_json) } 

      it 'has proper state variables restored from json' do 
          #pp base.to_json
          #pp restored.to_json
          expect(restored.name).to eq(base.name) 
      end 
  end
end
