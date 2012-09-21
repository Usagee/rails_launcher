module RailsLauncher
  class FileConstructor
    class MigrationIdGenerator
      def initialize(initial_id)
        @id = initial_id - 1
      end

      def next
        @id += 1
      end
    end
  end
end
