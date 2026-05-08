import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

df = pd.read_csv('/Users/danielwu/Desktop/SQL PROJECT/breast+cancer+wisconsin+diagnostic/breast_cancer.csv', header=None)

cols = [
    'id', 'diagnosis',
    'radius_mean', 'texture_mean', 'perimeter_mean', 'area_mean',
    'smoothness_mean', 'compactness_mean', 'concavity_mean', 'concave_points_mean',
    'symmetry_mean', 'fractal_dimension_mean',
    'radius_se', 'texture_se', 'perimeter_se', 'area_se',
    'smoothness_se', 'compactness_se', 'concavity_se', 'concave_points_se',
    'symmetry_se', 'fractal_dimension_se',
    'radius_worst', 'texture_worst', 'perimeter_worst', 'area_worst',
    'smoothness_worst', 'compactness_worst', 'concavity_worst', 'concave_points_worst',
    'symmetry_worst', 'fractal_dimension_worst'
]
df.columns = cols

password = quote_plus('your_password_here')
engine = create_engine(f'mysql+pymysql://root:{password}@127.0.0.1:3306/breast_cancer_analysis')
df.to_sql('tumor_data', con=engine, if_exists='replace', index=False)
print(f'Loaded {len(df)} rows successfully')

