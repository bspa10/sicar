package br.com.bsparaujo.sicar.familia.infra.mapper.jpa;

import br.com.bsparaujo.datatype.TipoDocumento;
import lombok.Data;
import org.hibernate.annotations.GenericGenerator;

import javax.persistence.*;
import java.io.Serializable;

@Data
@Entity
@Table(name = "pessoa")
@GenericGenerator(name = "generator", strategy = "PessoaGenerator")
public class PessoaEntity implements Serializable {

    @Id
    @Column(name = "pessoa", length = 7)
    @GeneratedValue(generator = "generator")
    private Long id;

    @Basic
    @Column(name = "tipo_documento", length = 1, nullable = false)
    @Convert(converter = TipoDocumentoConverter.class)
    private TipoDocumento tipoDocumento;

    @Column(name = "documento", length = 14, nullable = false)
    private String documento;

    @Column(length = 40, nullable = false)
    private String nome;

    @Column(length = 100, nullable = false)
    private String sobrenome;

    @Column(length = 100, nullable = false, unique = true)
    private String email;
}
