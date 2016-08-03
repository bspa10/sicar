package br.com.bsparaujo.sicar.familia.infra.mapper.jpa;

import lombok.Data;
import org.hibernate.annotations.GenericGenerator;

import javax.persistence.*;
import java.io.Serializable;

@Data
@Entity
@Table(name = "familia")
@GenericGenerator(name = "generator", strategy = "FamiliaGenerator")
public class FamiliaEntity implements Serializable {

    @Id
    @Column(name = "familia")
    @GeneratedValue(generator = "generator")
    private Long id;

    @Column(length = 20, nullable = false)
    private String nome;

    @Column(length = 40)
    private String sobrenome;

    @OneToOne(optional = false, fetch = FetchType.EAGER)
    @JoinColumn(name = "cabeca", referencedColumnName = "pessoa")
    private PessoaEntity cabeca;
}
