import os
import re
import json
from dotenv import load_dotenv
from langchain.vectorstores import Chroma
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains import RetrievalQA
from langchain.llms import HuggingFacePipeline
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
from langchain.chains import LLMChain
from langchain.chains import ConversationChain
from langchain.memory import ConversationBufferMemory
from langchain.prompts import PromptTemplate
from ml.prompt_templates import *

def clean_json(string):
    string = re.sub(",[ \t\r\n]+}", "}", string)
    string = re.sub(",[ \t\r\n]+\]", "]", string)

    return string

class DB:
    def __init__(self,
                 local_llm,
                 chain_type="stuff",
                 directory='./chroma_db',
                 model_name='sentence-transformers/all-MiniLM-L6-v2',
                 documents=[]):
        # init embeddings
        self.embeddings = HuggingFaceEmbeddings( model_name = model_name )
        self.documents = documents
        self.directory = directory
        self.local_llm = local_llm
        self.chain_type = chain_type
        self._init_db()

    def _init_db(self):
        if len(self.documents) == 0:
          return

        # split documents
        self.text_splitter = RecursiveCharacterTextSplitter(
                chunk_size = 1000, chunk_overlap = 200
        )
        self.splits = self.text_splitter.create_documents( self.documents )
        # create vector store
        if os.path.exists( self.directory ) == False:
            os.mkdir( self.directory )

        vector_store = Chroma.from_documents(
            documents = self.splits,
            embedding = self.embeddings,
            persist_directory = self.directory
        )

        # create retrieval chain
        self.qa_chain = RetrievalQA.from_chain_type(
                llm = self.local_llm,
                chain_type = self.chain_type,
                retriever = vector_store.as_retriever( search_kwargs={"k": 3} )
        )

    def add_document(self, doc):
      self.documents.append( doc )
      self._init_db()

    def query(self, text):
        return self.qa_chain.run( text )




"""
Must be called before creating a model.
The only thing this function does is setting up
models cache directory.
"""
def init_module():
    load_dotenv()
    if os.path.exists("./models") == False:
        os.mkdir('./models')
    os.environ["TRANSFORMERS_CACHE"] = os.getenv("MODEL_CACHE_DIR", "./models")

def new_model( model_name, max_length=65536, temperature=0.7 ):
    """
    Initialize a local transformer model for LangChain integration
    In:
        model_name - HuggingFace model identifier
    Out:
        llm - LangChain-compatible LLM instance
    """
    tokenizer = AutoTokenizer.from_pretrained( model_name )
    model = AutoModelForCausalLM.from_pretrained( model_name,
                                                 torch_dtype="auto",
                                                  device_map="auto" )

    # create huggingface pipeline
    hf_pipeline = pipeline(
        "text-generation",
        tokenizer = tokenizer,
        model = model,
        max_length = max_length,
        temperature = temperature,
        do_sample = True
    )
    llm = HuggingFacePipeline( pipeline = hf_pipeline )
    return llm

"""
Model for meal planner.
Constructor parameters are just basic parameters every model needs,
set with some sane values by default.

Model has 3 chats: meal planner, shopping list creator, receipt generator.
You should use the relevant function yourself.
"""
class Model:
    def __init__(self,
                 model_name,
                 database,
                 max_length=65536,
                 temperature=0.5,
                 verbose=True):
        # set vector database
        self.db = database
        # load model
        self.model = new_model( model_name, max_length, temperature )
        # initialize prompts for different tasks.
        self.receipt_gen_prompt = PromptTemplate(
                input_variables = ["meal", "forbidden_products"],
                template = RECEIPT_GEN_PROMPT
        )
        self.shopping_list_prompt = PromptTemplate(
            input_variables = ["meals", "forbidden_products"],
            template = SHOPPING_LIST_PROMPT
        )
        self.meal_plan_prompt = PromptTemplate(
            input_variables = ["forbidden_products", "available_products", "target_calories"],
            template = MEAL_PLAN_PROMPT
        )
        # initialize chats
        self.receipt_gen_chat = LLMChain(
                llm = self.model,
                prompt = self.receipt_gen_prompt,
                verbose = verbose
        )
        self.shopping_list_chat = LLMChain(
                llm = self.model,
                prompt = self.shopping_list_prompt,
                verbose = verbose
        )
        self.meal_plan_chat = LLMChain(
                llm = self.model,
                prompt = self.meal_plan_prompt,
                verbose = verbose
        )

    def save(self, receipt, meal):
      document_content = f"""Meal: {meal}
  Receipt:
    {receipt}
      """
      self.db.add_document( document_content )

    """
    Generates a meal plan for one day.
    In:
        forbidden_products - allergies and etc.
        available_products - products user wishes to include in their meal plan.
                             also the products user can afford.
        target_calories - string representing target calorial value: 'low', 'medium', 'high', etc.
    Out:
        meal_plan - dictionary, containing the list of food for breakfast, for lunch and dinner.
    """
    def gen_meal_plan(self, forbidden_products, available_products, target_calories):
        response = self.meal_plan_chat.run(
                forbidden_products = forbidden_products,
                available_products = available_products,
                target_calories = target_calories
        )
        response = '\n'.join(
            response.split('\n')[MEAL_PLAN_PROMPT.count('\n'):]
        )
        response = clean_json( response )
        print("generated meal plan:")
        print(response)
        print("-"*80)
        return json.loads( response )

    """
    Generates a shopping list based on meals.
    In:
        meals - a list of meals user would like to cook.
        forbidden_products - allergies and etc. (just in case something goes wrong)
    Out:
        shopping_list - pythonic list of products to buy.
    """
    def gen_shopping_list(self, meals, forbidden_products):
        response = self.shopping_list_chat.run(
                meals = meals,
                forbidden_products = forbidden_products,
        )
        response = clean_json( response )
        print(response)
        return json.loads( response )

    """
    Generates a receipt for a meal.
    In:
        meal - the name of meal to generate receipt for
        forbidden_products - allergies and etc. (because meal can contains some of these by default)
    Out:
        receipt - string description of how to cook a meal.
    """
    def gen_receipt(self, meal, forbidden_products):
        response = self.receipt_gen_chat.run(
                meal = meal,
                forbidden_products = forbidden_products,
        )
        print(response)
        return response
