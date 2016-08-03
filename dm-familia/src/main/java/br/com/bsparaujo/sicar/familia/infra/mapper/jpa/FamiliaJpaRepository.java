package br.com.bsparaujo.sicar.familia.infra.mapper.jpa;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

interface FamiliaJpaRepository extends JpaRepository<FamiliaEntity, Long> {

    @Query(
            name = "Familia.listByMembro",
            nativeQuery = true,
            value = "SELECT f.familia, f.cabeca, f.nome, f.sobrenome " +
                    "FROM sicar.familia f, sicar.familia_membro fm " +
                    "WHERE fm.familia = f.familia " +
                    "AND fm.membro = ?1"
    )
    List<FamiliaEntity> listByMembro(final long pessoaId);

    @Query("SELECT f FROM FamiliaEntity f WHERE f.cabeca.id = :cabecaId")
    FamiliaEntity findByCabeca(@Param("cabecaId") final long cabecaId);

    @Modifying
    @Query(
            name = "Familia.adicionarMembro",
            nativeQuery = true,
            value = "INSERT INTO sicar.familia_membro (familia, pessoa) VALUES (?1, ?2)"
    )
    void adicionarMembro(final long familiaId, final long pessoaId);

    @Modifying
    @Query(
            name = "Familia.removerMembro",
            nativeQuery = true,
            value = "DELETE sicar.familia_membro WHERE familia = ?1 AND pessoa = ?2"
    )
    void removerMembro(final long familiaId, final long pessoaId);
}
