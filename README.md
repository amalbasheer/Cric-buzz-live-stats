# Cricbuzz Live Stats Dashboard

A multi-page Streamlit web application for an interactive cricket dashboard, integrating live data from a hypothetical Cricbuzz API and utilizing a PostgreSQL database for additional data management.

## Features:

*   **Live Scorecards:** Real-time updates on ongoing matches (from API).
*   **Statistics Visualization:** Interactive charts for player statistics.
*   **Custom SQL Query Interface:** Execute SQL queries against the PostgreSQL database.
*   **Admin CRUD Operations:** Manage data entries in the database.

## Setup:

1.  **Clone this repository:**
    ```bash
    git clone https://github.com/your-username/cricbuzz_livestats.git
    cd cricbuzz_livestats
    ```

2.  **Install Python Dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

3.  **PostgreSQL Setup:**
    *   Ensure PostgreSQL is installed and running.
    *   Create a database (e.g., `sports_dashboard`).
    *   Update the `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` variables in `utils/db_connection.py` with your PostgreSQL credentials.

4.  **Cricbuzz API Setup:**
    *   **Crucial:** Obtain access to a Cricbuzz API (this project assumes a hypothetical one).
    *   Update `CRICBUZZ_API_BASE_URL` and `CRICBUZZ_API_KEY` in `cricbuzz_api.py` with your actual API details. You will need to implement the actual API call logic based on the API's documentation.

5.  **Run the Streamlit App:**
    ```bash
    streamlit run app.py
    ```

