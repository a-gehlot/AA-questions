require 'sqlite3'
require_relative 'questions.rb'
require_relative 'replies.rb'

class Users
attr_accessor :id, :fname, :lname

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def self.find_by_id(id)
        data = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                users
            WHERE
                id = ?
        SQL
        
        return nil unless data.length > 0
        Users.new(data.first)
    end

    def self.find_by_name(fname, lname)
        data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT
                *
            FROM
                users
            WHERE
                fname = ? AND lname = ?
        SQL

        data.map { |datum| Users.new(datum) }
    end

    def authored_questions
        Questions.find_by_author_id(@id)
    end

    def authored_replies
        Replies.find_by_user_id(@id)
    end

    def followed_questions
        QuestionFollows.followed_questions_for_user_id(@id)
    end

    def liked_questions
        QuestionLikes.liked_questions_for_user_id(@id)
    end

    def average_karma
        data = QuestionsDatabase.instance.execute(<<-SQL, @id)
            SELECT
                CAST(COUNT(question_likes.question_id) AS FLOAT) / 
                COUNT(DISTINCT(questions.id)) AS avg_karma
            FROM
                questions
            LEFT OUTER JOIN
                question_likes ON questions.id = question_likes.question_id
            WHERE
                questions.id = ?
        SQL
    end

    def save
        if @id.nil?
            QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
                INSERT INTO
                    users (fname, lname)
                VALUES
                    (?, ?)
            SQL

            @id = QuestionsDatabase.instance.last_insert_row_id
        else
            update
        end
    end

    def update
        raise "not in database" unless @id
        QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
            UPDATE
                users
            SET
                fname = ?, lname = ?
            WHERE
                id = ?
        SQL
    end
end