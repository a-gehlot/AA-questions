require 'sqlite3'
require_relative 'users.rb'

class Replies
    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @user_id = options['user_id']
        @parent_id = options['parent_id']
        @body = options['body']
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                replies
            WHERE
                id = ?
        SQL
        return nil unless data.length > 0
        Replies.new(data.first)
    end

    def self.find_by_user_id(user_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                replies
            WHERE
                user_id = ?
        SQL

        data.map { |datum| Replies.new(datum) }
    end    
    
    def self.find_by_question_id(question_id)
        data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                replies
            WHERE
                question_id = ?
        SQL

        data.map { |datum| Replies.new(datum) }
    end

    def author
        data = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
            SELECT
                *
            FROM
                users
            WHERE
                id = ?
        SQL

        data.map { |datum| Users.new(datum) }
    end

    def question
        data = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
            SELECT
                *
            FROM
                questions
            WHERE
                id = ?
        SQL

        data.map { |datum| Questions.new(datum) }
    end

    def parent_reply
        data = QuestionsDatabase.instance.execute(<<-SQL, @parent_id)
            SELECT
                *
            FROM
                replies
            WHERE
                user_id = ?
        SQL

        data.map { |datum| Replies.new(datum) }
    end

    def child_replies
        data = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
            SELECT
                *
            FROM
                replies
            WHERE
                parent_id = ?
        SQL

        data.map { |datum| Replies.new(datum) }
    end

    def save
        if @id.nil?
            QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @parent_id, @body)
                INSERT INTO
                    users (question_id, user_id, parent_id, body)
                VALUES
                    (?, ?, ?, ?)
            SQL

            @id = QuestionsDatabase.instance.last_insert_row_id
        else
            update
        end
    end

    def update
        raise "not in database" unless @id
        QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @parent_id, @body, @id)
            UPDATE
                users
            SET
                question_id = ?, user_id = ?, parent_id = ?, body = ?
            WHERE
                id = ?
        SQL
    end

end