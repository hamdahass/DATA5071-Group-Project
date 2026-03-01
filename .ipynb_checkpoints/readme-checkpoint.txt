{
 "cells": [
  {
   "cell_type": "markdown",
   "id": "6ae7b0cc-c097-4dfa-8152-55883776115c",
   "metadata": {},
   "source": [
    "# Pandas Optimization"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f9cef9c2-73fd-4e32-9907-ee995d2505a0",
   "metadata": {},
   "source": [
    "## 1: Converting Columns to Category"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "9eb56f17-a3f2-4b9f-a50a-7a4eea79d2db",
   "metadata": {},
   "source": [
    "Columns in our dataset such as state_code, category, and parameter_name are stored as object (string) types. Since these columns contain repeated values, converting them to the category type reduces memory usage and improves filtering performance. Categorical data stores each unique value only once and replaces the actual strings with integer codes internally, making operations more efficient.\n",
    "\n",
    "After converting to categorical types, memory usage decreased and groupby operations became faster. This is useful for large datasets with repeated string values."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b09ea711-a99d-4caf-aff6-d74cfcb75b49",
   "metadata": {},
   "source": [
    "## 2: Using .query() for Filtering"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f2ebd340-031b-4870-8cc8-f39bfb42004f",
   "metadata": {},
   "source": [
    "Instead of filtering using boolean indexing, we used the .query() method. The .query() method can improve performance when filtering large datasets. The .query() method is cleaner and slightly faster than boolean indexing."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "4f21a5cc-2e2b-4510-ac21-390786e9cba9",
   "metadata": {},
   "source": [
    "## 3: Using set_index() for Faster Lookups\n",
    "Since we frequently filter by state_code, setting it as the DataFrame index allows faster row selection using .loc[]. When a column is used often for filtering, making it the index avoids scanning the entire column each time."
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python [conda env:base] *",
   "language": "python",
   "name": "conda-base-py"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.13.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
