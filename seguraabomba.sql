// Use DBML to define your database structure
// Docs: https://dbml.dbdiagram.io/docs

Table area {
  sigla varchar(10) [pk, not null, unique] // PK da área
  nome varchar(100) [not null, unique] // Nome não pode repetir
  superarea varchar(100) // Pode ser nulo (área raiz não tem superárea)
}

Table curso {
  sigla varchar(10) [pk, not null] // PK do curso
  nome varchar(100) [not null, unique] // Cada curso tem nome único
  horas int [not null, note: 'Carga horária total em horas']
  custo decimal(10,2) [not null, default: 0.00]
  area varchar(10) [not null, ref: > area.sigla] // FK para área
}

Table modulo {
  sigla varchar(10) [pk, not null] // PK do módulo
  nome varchar(100) [not null]
  curso varchar(10) [not null, ref: > curso.sigla] // FK para curso
}

Table topico {
  sigla varchar(10) [pk, not null] // PK do tópico
  nome text [not null] // Conteúdo pode ser longo
  horas int [not null, default: 1, note: 'Horas dedicadas ao tópico']
  modulo varchar(10) [not null, ref: > modulo.sigla] // FK para módulo
}

Table aluno {
  cpf char(11) [pk, not null] // CPF como PK
  nome varchar(50) [not null]
  sobrenome varchar(50) [not null]
  sexo char(1) [not null, note: 'M/F/O'] // domínio restrito
  datanasc date [not null]
}

Table professor {
  cpf char(11) [pk, not null] // PK professor
  nome varchar(100) [not null]
  curso varchar(10) [not null, ref: > curso.sigla] // Professor vinculado a curso
}

Table matricula {
  id serial [pk] // PK artificial para matrícula
  curso varchar(10) [not null, ref: > curso.sigla]
  aluno char(11) [not null, ref: > aluno.cpf]
  data date [not null, default: `now()`]
  pago bool [not null, default: false]

  Note: 'Um aluno só pode se matricular uma vez em um curso (UNIQUE)'

  Indexes {
    (curso, aluno) [unique] // Evita duplicidade
  }
}
