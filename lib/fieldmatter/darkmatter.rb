# FieldMatter::DarkMatter

# require

class FieldMatter
  class DarkMatter
    attr_reader :repo, :repo_path, :what_matters
    
    def initialize( repo_path )
      @repo_path = repo_path
    end

    def repo
      Grit::Repo.new(self.repo_path)
    end

    def what_matters
      JSON.parse((self.repo.tree / 'fieldmatter.json').data)
    end

    def update 
      self.what_matters.each do | key, value |
        if not FieldMatter::Note.find(filename: key).empty?
          canon = Base64.encode64(key).chomp
          id = Ohm.redis.smembers("FieldMatter::Note:filename:#{canon}").pop
          note = FieldMatter::Note[id]
          note.update(:tags => value['kMDItemOMUserTags'].join(', '))
        else
          FieldMatter::Note.create(:filename => key, :tags => value['kMDItemOMUserTags'].join(', '))
        end
      end
    end
  end
end
