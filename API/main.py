from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from passlib.context import CryptContext
from datetime import datetime

# --- CONFIGURACIÓN BD ---
# Asegúrate de que esta línea tenga tus credenciales correctas (como lo corregimos antes)
SQLALCHEMY_DATABASE_URL = "mssql+pyodbc://(localdb)\MSSQLLocalDB/AppDistribuidora?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Cambia a "argon2" si seguiste mi recomendación anterior, o déjalo en "bcrypt" si lograste instalar la versión vieja.
pwd_context = CryptContext(schemes=["argon2"], deprecated="auto") 

app = FastAPI()

# --- CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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

# --- NUEVO MODELO: Rutas ---
class RouteDB(Base):
    __tablename__ = "Routes"
    ID = Column(Integer, primary_key=True, index=True)
    NombreRuta = Column(String)
    ZonaAsignada = Column(String)
    FechaCreacion = Column(DateTime, default=datetime.now)
    NumTiendas = Column(Integer)
    Descripcion = Column(String)

Base.metadata.create_all(bind=engine)

# --- ESQUEMAS Pydantic ---
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

# --- NUEVO ESQUEMA: Rutas ---
class RouteCreate(BaseModel):
    nombre_ruta: str
    zona_asignada: str
    num_tiendas: int
    descripcion: str

# --- DEPENDENCIAS ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- ENDPOINTS EXISTENTES ---

@app.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(UserDB).filter(UserDB.Email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="El correo ya existe")
    
    hashed_pw = pwd_context.hash(user.password)
    new_user = UserDB(Nombre=user.nombre, Email=user.em1ail, Rol=user.rol, PasswordHash=hashed_pw)
    db.add(new_user)
    db.commit()
    return {"mensaje": "Usuario creado exitosamente"}

@app.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(UserDB).filter(UserDB.Email == user.email).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="Usuario no existe")
    
    if not pwd_context.verify(user.password, db_user.PasswordHash):
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")
    
    return {"mensaje": "Login exitoso", "usuario": db_user.Nombre, "rol": db_user.Rol}

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

@app.get("/pedidos")
def get_orders(db: Session = Depends(get_db)):
    return db.query(OrderDB).all()

# --- NUEVOS ENDPOINTS: CRUD Rutas ---

# 1. Crear Ruta
@app.post("/rutas")
def create_route(route: RouteCreate, db: Session = Depends(get_db)):
    new_route = RouteDB(
        NombreRuta=route.nombre_ruta,
        ZonaAsignada=route.zona_asignada,
        NumTiendas=route.num_tiendas,
        Descripcion=route.descripcion
    )
    db.add(new_route)
    db.commit()
    return {"mensaje": "Ruta creada exitosamente"}

# 2. Listar Rutas
@app.get("/rutas")
def get_routes(db: Session = Depends(get_db)):
    return db.query(RouteDB).all()

# 3. Obtener una Ruta por ID
@app.get("/rutas/{ruta_id}")
def get_route(ruta_id: int, db: Session = Depends(get_db)):
    route = db.query(RouteDB).filter(RouteDB.ID == ruta_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Ruta no encontrada")
    return route

# 4. Actualizar Ruta
@app.put("/rutas/{ruta_id}")
def update_route(ruta_id: int, route_data: RouteCreate, db: Session = Depends(get_db)):
    db_route = db.query(RouteDB).filter(RouteDB.ID == ruta_id).first()
    if not db_route:
        raise HTTPException(status_code=404, detail="Ruta no encontrada")
    
    db_route.NombreRuta = route_data.nombre_ruta
    db_route.ZonaAsignada = route_data.zona_asignada
    db_route.NumTiendas = route_data.num_tiendas
    db_route.Descripcion = route_data.descripcion
    
    db.commit()
    return {"mensaje": "Ruta actualizada correctamente"}

# 5. Eliminar Ruta
@app.delete("/rutas/{ruta_id}")
def delete_route(ruta_id: int, db: Session = Depends(get_db)):
    db_route = db.query(RouteDB).filter(RouteDB.ID == ruta_id).first()
    if not db_route:
        raise HTTPException(status_code=404, detail="Ruta no encontrada")
    
    db.delete(db_route)
    db.commit()
    return {"mensaje": "Ruta eliminada correctamente"}

# --- AGREGAR AL FINAL DE API/main.py ---

# 5. Actualizar Pedido
@app.put("/pedidos/{pedido_id}")
def update_order(pedido_id: int, order: OrderCreate, db: Session = Depends(get_db)):
    db_order = db.query(OrderDB).filter(OrderDB.ID == pedido_id).first()
    if not db_order:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    
    db_order.ClienteNombre = order.cliente_nombre
    db_order.Telefono = order.telefono
    db_order.FechaEntrega = order.fecha_entrega
    db_order.Vendedor = order.vendedor
    db_order.DireccionEntrega = order.direccion
    
    db.commit()
    return {"mensaje": "Pedido actualizado correctamente"}

# 6. Eliminar Pedido
@app.delete("/pedidos/{pedido_id}")
def delete_order(pedido_id: int, db: Session = Depends(get_db)):
    db_order = db.query(OrderDB).filter(OrderDB.ID == pedido_id).first()
    if not db_order:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    
    db.delete(db_order)
    db.commit()
    return {"mensaje": "Pedido eliminado correctamente"}