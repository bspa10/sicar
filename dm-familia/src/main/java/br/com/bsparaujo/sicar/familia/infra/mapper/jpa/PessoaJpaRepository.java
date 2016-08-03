package br.com.bsparaujo.sicar.familia.infra.mapper.jpa;

import org.springframework.data.jpa.repository.JpaRepository;

interface PessoaJpaRepository extends JpaRepository<PessoaEntity, Long> {

    PessoaEntity findByEmail(final String email);

}
