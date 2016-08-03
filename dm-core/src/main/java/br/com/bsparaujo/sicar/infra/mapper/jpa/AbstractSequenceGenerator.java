package br.com.bsparaujo.sicar.infra.mapper.jpa;

import org.hibernate.HibernateException;
import org.hibernate.engine.spi.SessionImplementor;
import org.hibernate.id.IdentifierGenerator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.Serializable;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public abstract class AbstractSequenceGenerator implements IdentifierGenerator  {
    private static final Logger LOGGER = LoggerFactory.getLogger(AbstractSequenceGenerator.class);

    private final byte sequencia;

    public AbstractSequenceGenerator(byte sequencia) {
        LOGGER.trace("Iniciando gerador da sequencia {}", sequencia);
        this.sequencia = sequencia;
    }

    @Override
    public final Serializable generate(final SessionImplementor session, final Object object) throws HibernateException {
        LOGGER.debug("Gerando sequencia \'{}\'", sequencia);
        final Connection connection = session.connection();

        ResultSet resultSet;
        try (final Statement statement = connection.createStatement()){
            resultSet = statement.executeQuery("SELECT f_seq_nextval("+ sequencia +")");

            if(resultSet.next()) {
                long valorGerado = resultSet.getLong(1);

                LOGGER.debug("SELECT sicar.f_seq_nextval({}) = {}", sequencia, valorGerado);
                return valorGerado;
            }

        } catch (SQLException e) {
            LOGGER.error("Não foi possível gerar id para sequencia \'{}\'. Movito: {}", sequencia, e.toString());

        }

        return 0L;
    }
}
