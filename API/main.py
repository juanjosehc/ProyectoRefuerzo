from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from passlib.context import CryptContext
from datetime import datetime

# --- CONFIGURACIÓN BD (Ajusta SERVER y UID/PWD) ---
# Usa autenticación de Windows (Trusted_Connection) o usuario/pass
SQLALCHEMY_DATABASE_URL = "mssql+pyodbc://@SERVER_NAME/AppDistribuidora?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

app = FastAPI()

# --- MODELOS BD ---
class UserDB(Base):
    __tablename__ = "Users"
    ID = Column(Integer, primary_key=True, index=True)
    Nombre = Column(String)
    Email = Column(String, unique=True)
    Rol = Column(String)
    PasswordHash = Column(String)

class OrderDB(Base):
    __tablename__ = "Orders"
    ID = Column(Integer, primary_key=True, index=True)
    ClienteNombre = Column(String)
    Telefono = Column(String)
    FechaPedido = Column(DateTime, default=datetime.now)
    FechaEntrega = Column(DateTime)
    Vendedor = Column(String)
    DireccionEntrega = Column(String)

Base.metadata.create_all(bind=engine)

# --- ESQUEMAS Pydantic (Para recibir datos) ---
class UserCreate(BaseModel):
    nombre: str
    email: str
    password: str
    rol: str = "Usuario"

class UserLogin(BaseModel):
    email: str
    password: str

class OrderCreate(BaseModel):
    cliente_nombre: str
    telefono: str
    fecha_entrega: datetime
    vendedor: str
    direccion: str

# --- DEPENDENCIAS ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- ENDPOINTS ---

# 1. Registro
@app.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(UserDB).filter(UserDB.Email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="El correo ya existe")
    
    hashed_pw = pwd_context.hash(user.password)
    new_user = UserDB(Nombre=user.nombre, Email=user.email, Rol=user.rol, PasswordHash=hashed_pw)
    db.add(new_user)
    db.commit()
    return {"mensaje": "Usuario creado exitosamente"}

# 2. Login
@app.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(UserDB).filter(UserDB.Email == user.email).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Usuario no existe") # Validación pedida
    
    if not pwd_context.verify(user.password, db_user.PasswordHash):
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")
    
    return {"mensaje": "Login exitoso", "usuario": db_user.Nombre, "rol": db_user.Rol}

# 3. Crear Pedido
@app.post("/pedidos")
def create_order(order: OrderCreate, db: Session = Depends(get_db)):
    new_order = OrderDB(
        ClienteNombre=order.cliente_nombre,
        Telefono=order.telefono,
        FechaEntrega=order.fecha_entrega,
        Vendedor=order.vendedor,
        DireccionEntrega=order.direccion
    )
    db.add(new_order)
    db.commit()
    return {"mensaje": "Pedido creado"}

# 4. Listar Pedidos
@app.get("/pedidos")
def get_orders(db: Session = Depends(get_db)):
    return db.query(OrderDB).all()

# Para ejecutar: uvicorn main:app --reload --host 0.0.0.0