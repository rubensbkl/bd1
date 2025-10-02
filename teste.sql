-- =====================================================
-- Script de Inicialização do Banco de Dados
-- Sistema de Gestão de Cursos
-- =====================================================

-- Criar schema (opcional, mas recomendado)
CREATE SCHEMA IF NOT EXISTS cursos;

-- Definir o schema padrão para esta sessão
SET search_path TO cursos, public;

-- =====================================================
-- TABELA: area
-- Hierarquia de áreas de conhecimento
-- =====================================================
CREATE TABLE area (
    sigla VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    superarea VARCHAR(100),
    
    -- Constraint para garantir que superarea existe
    CONSTRAINT fk_area_superarea 
        FOREIGN KEY (superarea) 
        REFERENCES area(sigla)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Índice para busca por superarea
CREATE INDEX idx_area_superarea ON area(superarea);

COMMENT ON TABLE area IS 'Áreas de conhecimento organizadas hierarquicamente';
COMMENT ON COLUMN area.sigla IS 'Sigla única da área (PK)';
COMMENT ON COLUMN area.nome IS 'Nome completo da área';
COMMENT ON COLUMN area.superarea IS 'Área pai na hierarquia (pode ser nulo para áreas raiz)';

-- =====================================================
-- TABELA: curso
-- Cursos oferecidos pela instituição
-- =====================================================
CREATE TABLE curso (
    sigla VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    horas INTEGER NOT NULL CHECK (horas > 0),
    custo DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (custo >= 0),
    area VARCHAR(10) NOT NULL,
    
    CONSTRAINT fk_curso_area 
        FOREIGN KEY (area) 
        REFERENCES area(sigla)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Índice para busca por área
CREATE INDEX idx_curso_area ON curso(area);

COMMENT ON TABLE curso IS 'Cursos disponíveis no sistema';
COMMENT ON COLUMN curso.sigla IS 'Sigla única do curso (PK)';
COMMENT ON COLUMN curso.nome IS 'Nome completo do curso';
COMMENT ON COLUMN curso.horas IS 'Carga horária total em horas';
COMMENT ON COLUMN curso.custo IS 'Custo do curso em reais';
COMMENT ON COLUMN curso.area IS 'Área de conhecimento do curso';

-- =====================================================
-- TABELA: modulo
-- Módulos que compõem os cursos
-- =====================================================
CREATE TABLE modulo (
    sigla VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    curso VARCHAR(10) NOT NULL,
    
    CONSTRAINT fk_modulo_curso 
        FOREIGN KEY (curso) 
        REFERENCES curso(sigla)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Índice para busca por curso
CREATE INDEX idx_modulo_curso ON modulo(curso);

COMMENT ON TABLE modulo IS 'Módulos que dividem os cursos';
COMMENT ON COLUMN modulo.sigla IS 'Sigla única do módulo (PK)';
COMMENT ON COLUMN modulo.nome IS 'Nome do módulo';
COMMENT ON COLUMN modulo.curso IS 'Curso ao qual o módulo pertence';

-- =====================================================
-- TABELA: topico
-- Tópicos de conteúdo dentro dos módulos
-- =====================================================
CREATE TABLE topico (
    sigla VARCHAR(10) PRIMARY KEY,
    nome TEXT NOT NULL,
    horas INTEGER NOT NULL DEFAULT 1 CHECK (horas > 0),
    modulo VARCHAR(10) NOT NULL,
    
    CONSTRAINT fk_topico_modulo 
        FOREIGN KEY (modulo) 
        REFERENCES modulo(sigla)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Índice para busca por módulo
CREATE INDEX idx_topico_modulo ON topico(modulo);

COMMENT ON TABLE topico IS 'Tópicos de conteúdo dentro dos módulos';
COMMENT ON COLUMN topico.sigla IS 'Sigla única do tópico (PK)';
COMMENT ON COLUMN topico.nome IS 'Conteúdo/descrição do tópico';
COMMENT ON COLUMN topico.horas IS 'Horas dedicadas ao tópico';
COMMENT ON COLUMN topico.modulo IS 'Módulo ao qual o tópico pertence';

-- =====================================================
-- TABELA: aluno
-- Cadastro de alunos
-- =====================================================
CREATE TABLE aluno (
    cpf CHAR(11) PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    sexo CHAR(1) NOT NULL CHECK (sexo IN ('M', 'F', 'O')),
    datanasc DATE NOT NULL,
    
    CONSTRAINT chk_aluno_idade 
        CHECK (datanasc <= CURRENT_DATE - INTERVAL '16 years')
);

-- Índice para busca por nome
CREATE INDEX idx_aluno_nome ON aluno(nome, sobrenome);

COMMENT ON TABLE aluno IS 'Cadastro de alunos';
COMMENT ON COLUMN aluno.cpf IS 'CPF do aluno (PK)';
COMMENT ON COLUMN aluno.nome IS 'Primeiro nome do aluno';
COMMENT ON COLUMN aluno.sobrenome IS 'Sobrenome do aluno';
COMMENT ON COLUMN aluno.sexo IS 'Sexo do aluno (M/F/O)';
COMMENT ON COLUMN aluno.datanasc IS 'Data de nascimento';

-- =====================================================
-- TABELA: professor
-- Cadastro de professores
-- =====================================================
CREATE TABLE professor (
    cpf CHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    curso VARCHAR(10) NOT NULL,
    
    CONSTRAINT fk_professor_curso 
        FOREIGN KEY (curso) 
        REFERENCES curso(sigla)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Índice para busca por curso
CREATE INDEX idx_professor_curso ON professor(curso);

COMMENT ON TABLE professor IS 'Cadastro de professores vinculados a cursos';
COMMENT ON COLUMN professor.cpf IS 'CPF do professor (PK)';
COMMENT ON COLUMN professor.nome IS 'Nome completo do professor';
COMMENT ON COLUMN professor.curso IS 'Curso ao qual o professor está vinculado';

-- =====================================================
-- TABELA: matricula
-- Matrículas de alunos em cursos
-- =====================================================
CREATE TABLE matricula (
    id SERIAL PRIMARY KEY,
    curso VARCHAR(10) NOT NULL,
    aluno CHAR(11) NOT NULL,
    data DATE NOT NULL DEFAULT CURRENT_DATE,
    pago BOOLEAN NOT NULL DEFAULT FALSE,
    
    CONSTRAINT fk_matricula_curso 
        FOREIGN KEY (curso) 
        REFERENCES curso(sigla)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_matricula_aluno 
        FOREIGN KEY (aluno) 
        REFERENCES aluno(cpf)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Evita duplicidade: um aluno só pode se matricular uma vez em cada curso
    CONSTRAINT uk_matricula_curso_aluno 
        UNIQUE (curso, aluno)
);

-- Índices para otimizar consultas
CREATE INDEX idx_matricula_curso ON matricula(curso);
CREATE INDEX idx_matricula_aluno ON matricula(aluno);
CREATE INDEX idx_matricula_data ON matricula(data);

COMMENT ON TABLE matricula IS 'Registro de matrículas de alunos em cursos';
COMMENT ON COLUMN matricula.id IS 'ID único da matrícula (PK)';
COMMENT ON COLUMN matricula.curso IS 'Curso da matrícula';
COMMENT ON COLUMN matricula.aluno IS 'Aluno matriculado';
COMMENT ON COLUMN matricula.data IS 'Data da matrícula';
COMMENT ON COLUMN matricula.pago IS 'Indica se o curso foi pago';

-- =====================================================
-- VIEWS ÚTEIS
-- =====================================================

-- View com informações completas de matrícula
CREATE VIEW v_matriculas_completas AS
SELECT 
    m.id,
    m.data,
    m.pago,
    c.sigla AS curso_sigla,
    c.nome AS curso_nome,
    c.horas AS curso_horas,
    c.custo AS curso_custo,
    a.cpf AS aluno_cpf,
    a.nome || ' ' || a.sobrenome AS aluno_nome_completo,
    a.datanasc AS aluno_data_nascimento,
    EXTRACT(YEAR FROM AGE(a.datanasc)) AS aluno_idade
FROM matricula m
JOIN curso c ON m.curso = c.sigla
JOIN aluno a ON m.aluno = a.cpf;

COMMENT ON VIEW v_matriculas_completas IS 'View com informações detalhadas das matrículas';

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================