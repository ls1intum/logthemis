from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.document_loaders import TextLoader
import requests
import os

openai_api_key = ""

decision_system_prompt1 = """
    You are a log analyzer specialist.
    Your job is to assist the user with understanding large log files.
    For this you have search access to the log file.
    To search a log file you need to provide a string which is then used for a similarity search.
    You should now decide if you need to search the log file or not.
    This is the user query:
    """

decision_system_prompt2 = """
    Respond with "yes" if you need to search the log file. Otherwise respond with "no".
    """

gen_example_system_prompt = """
    You are a log analyzer specialist.
    Your job is to assist the user with understanding large log files.
    For this you have search access to the log file.
    To search a log file you need to provide a string which is then used for a similarity search.
    You can provide multiple string for the similarity search.
    Each search string needs to be on its own line.
    Each search string should be an excerpt from an actual Linux trace log.
    These are a couple example files from such a log file:
    > Nov 09 13:11:45 CMX50070-101776 kernel: CMX_IOCTL_GET_SLOT_ID call
    > Nov 09 13:11:45 CMX50070-101776 avahi-daemon[379]: New relevant interface docker0.IPv4 for mDNS.
    > Nov 09 13:11:45 CMX50070-101776 xu_launcher[2941]: ./five_12.bmp
    > Nov 10 05:49:04 CMX50070-101776 systemd[1]: Stopping The NGINX HTTP and reverse proxy server...
    > Nov 09 13:11:37 CMX50070-101776 systemd[1]: Listening on Docker Socket for the API.
    Example start ----
    User: "Is there a not authorized ssh login try in these login files?"
    You:\"\"\"
    hostname sshd[0000]: Failed password for invalid user USERID from 10.0.2.217 port 41888 ssh2
    hostname sshd[0000]: Connection closed by invalid user USERID 0.0.0.0 port 00000 [preauth]
    hostname sshd[0000]: Failed none for invalid user b734a2zih
    hostname sshd[0000]: Invalid user USERID from 10.0.2.217 port 41888
    \"\"\"
    ------ Example end
    Example start ----
    User: "Was a NullPointerException thrown?"
    You:\"\"\"
    Exception in thread "main" java.lang.NullPointerException
    java.lang.NullPointerException
    at foo.bar(Foo.class:111)
    \"\"\"
    ------ Example end
    This is only a simple example, please ensure that you are as specific, but general as possible when creating the search strings.
    In the future please always generate **10** DISTINCT search strings.
    DO generate distinct strings.
    Do NOT generate redundant strings where the only difference is e.g. the username or some id.
    INSTEAD generate a wide variety of strings that might be helpful. The broader the better.
    DO NOT repeat yourself. INSTEAD find new search strings that were not already given.
    See the example above for the variance that should be between the search strings.
    """


def answer_system_prompt(final_result):
    return f"""
        You are a log analyzer specialist.
        Your job is to assist the user with understanding large log files.
        The user will ask you a question and we provide you with relevant excerpts from the log.
        You should then respond to the users query using the log excerpts.
        Unless specifically asked do NOT forward the raw log entries to the user. 
        Instead summarize the log entries with some small and specific excerpts.
        We have selected the following lines to be relevant to the users query:
        ```
        {final_result}
        ```
        """


class AI:
    def __init__(self):
        self.embeddings = OpenAIEmbeddings(openai_api_key=openai_api_key)
        self.stores = {}

        if os.path.exists("./db_log1/chroma.sqlite3"):
            self.stores["log1"] = Chroma(collection_name="log1", persist_directory="db_log1", embedding_function=self.embeddings)
        else:
            self.stores["log1"] = self.create_vector_db("./data/logs/test1.log", "log1")

        if os.path.exists("./db_log2/chroma.sqlite3"):
            self.stores["log2"] = Chroma(collection_name="log2", persist_directory="db_log2", embedding_function=self.embeddings)
        else:
            self.stores["log2"] = self.create_vector_db("./data/logs/test2.log", "log2")

        if os.path.exists("./db_log3/chroma.sqlite3"):
            self.stores["log3"] = Chroma(collection_name="log3", persist_directory="db_log3", embedding_function=self.embeddings)
        else:
            self.stores["log3"] = self.create_vector_db("./data/logs/test3.log", "log3")

        print("All stores created")

        self.log_files = {}
        self.log_files["log1"] = open("./data/logs/test1.log", "r").read().split('\n')
        self.log_files["log2"] = open("./data/logs/test2.log", "r").read().split('\n')
        self.log_files["log3"] = open("./data/logs/test3.log", "r").read().split('\n')

        self.message_histories = {}

    def create_vector_db(self, logfile, collection_name):
        print("Creating DB for " + logfile + " ...")
        loader = TextLoader(logfile)
        docs = loader.load()
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=500,
            chunk_overlap=50,
            length_function=len,
            is_separator_regex=False,
        )
        texts = text_splitter.split_documents(docs)
        store = Chroma.from_documents(
            texts,
            self.embeddings,
            ids=[f"{item.metadata['source']}--{index}" for index, item in enumerate(texts)],
            collection_name=collection_name,
            persist_directory='db_' + collection_name
        )
        store.persist()
        return store

    def query_openai(self, messages):
        headers = {
            "Authorization": f"Bearer {openai_api_key}",
            "OpenAI-Organization": "org-Jxi1EsvgxtuuKkYvRp5uoYSt"
        }
        data = {
            "model": "gpt-4-1106-preview",
            "messages": messages,
            "max_tokens": 500,
            "temperature": 0
        }
        response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=data)
        return response.json()

    def get_line_number(self, log_file, text):
        lines = self.log_files[log_file]
        for index, line in enumerate(lines):
            if text in line:
                return index

    def generate_response(self, user_prompt, log_file, session_id):
        store = self.stores[log_file]
        message_history = self.message_histories.get(session_id, [])

        messages = [
            {"role": "system", "content": f"{decision_system_prompt1}"},
            {"role": "user", "content": f"{user_prompt}"},
            {"role": "system", "content": f"{decision_system_prompt2}"}
        ]

        response = self.query_openai(messages)
        response = response['choices'][0]['message']['content']
        if response.startswith("y"):
            messages = [
                {"role": "system", "content": f"{gen_example_system_prompt}"},
                {"role": "user", "content": f"{user_prompt}"},
                {"role": "assistant", "content": "Search for:"}
            ]

            response = self.query_openai(messages)
            search_strings = response['choices'][0]['message']['content'].splitlines()
            query_results = []
            for s in search_strings:
                print("- " + s)
                query_result = store.search(query=s, search_type="similarity")
                print(len(query_result))
                query_results += query_result
            #query_results = list(set([qr.page_content for qr in query_results]))

            flat_list = []
            for qr in query_results:
                flat_list.extend(qr.page_content.splitlines())

            query_results = [f"L{self.get_line_number(log_file, qr)}> {qr}" for qr in flat_list]
            final_result = "\n".join(query_results)
            print(final_result)

            asp = answer_system_prompt(final_result)
            print("Search")
        else:
            asp = answer_system_prompt('')
            print("No search")

        messages = [
            {"role": "system", "content": f"{asp}"},
            {"role": "user", "content": f"{user_prompt}"}
        ]
        response = self.query_openai(messages)

        actual_response = response['choices'][0]['message']['content']
        message_history += asp
        message_history += user_prompt
        message_history += actual_response
        self.message_histories[session_id] = message_history
        return actual_response
