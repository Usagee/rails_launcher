class RailsLauncher::FileConstructor
  class FileEntity
    def to_s
      path
    end

    # Relative path to rails root.
    # Every subclass should implement this method.
    #
    def path
      raise NotImplementedError
    end

    # File content in String
    # Every subclass should implement this method.
    #
    def file_content
      raise NotImplementedError
    end
  end
end
